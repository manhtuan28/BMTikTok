#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BMTikTok IPA Injector Tool
Created by Tuancute28 (Bùi Mạnh Tuấn)

Tự động giải nén IPA TikTok gốc, chèn BMTikTok.dylib, libsubstrate.dylib, BMTikTok.bundle,
loại bỏ các PlugIns/Extensions/Watch để tối ưu chỉ cần 1 App ID khi Sideload (Sideloadly / AltStore),
sửa liên kết CydiaSubstrate sang @rpath/libsubstrate.dylib để chạy trên máy không Jailbreak,
và đóng gói thành phẩm BMTikTok IPA hoàn chỉnh.
"""

import sys
import os
import shutil
import zipfile
import struct
import argparse
import subprocess
import plistlib

# ═══════════════════════════════════════════════════════════════
# Mach-O Code Signature Stripping
# Fix TrollStore ldid crash: "target.sputn(data, writ) == writ"
# ═══════════════════════════════════════════════════════════════

LC_CODE_SIGNATURE = 0x1d

def _strip_macho_slice_signature(f, base_offset):
    """Tìm và xóa `LC_CODE_SIGNATURE` trong một Mach-O 64-bit slice, cắt bỏ dữ liệu chữ ký cuối file."""
    f.seek(base_offset)
    header = f.read(32)
    magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags, reserved = struct.unpack('<IIIIIIII', header)

    offset_cursor = base_offset + 32
    codesig_cmd_offset = None
    codesig_dataoff = None

    for i in range(ncmds):
        f.seek(offset_cursor)
        cmd_hdr = f.read(8)
        if len(cmd_hdr) < 8:
            break
        cmd, cmdsize = struct.unpack('<II', cmd_hdr)

        if cmd == LC_CODE_SIGNATURE:
            # LC_CODE_SIGNATURE payload: dataoff (4 bytes) + datasize (4 bytes)
            sig_payload = f.read(8)
            dataoff, datasize = struct.unpack('<II', sig_payload)
            codesig_cmd_offset = offset_cursor
            codesig_dataoff = dataoff
            codesig_cmdsize = cmdsize

            # 1. Dịch chuyển các load commands phía sau lên để không tạo khoảng trống Cmd 0x0 size 0
            remaining_bytes_offset = codesig_cmd_offset + codesig_cmdsize
            end_of_cmds = base_offset + 32 + sizeofcmds
            if remaining_bytes_offset < end_of_cmds:
                f.seek(remaining_bytes_offset)
                remaining_cmds = f.read(end_of_cmds - remaining_bytes_offset)
                f.seek(codesig_cmd_offset)
                f.write(remaining_cmds)
                f.write(b'\x00' * codesig_cmdsize)
            else:
                f.seek(codesig_cmd_offset)
                f.write(b'\x00' * codesig_cmdsize)

            # 2. Giảm ncmds và sizeofcmds trong Mach-O header
            f.seek(base_offset + 16)
            f.write(struct.pack('<II', ncmds - 1, sizeofcmds - codesig_cmdsize))

            return codesig_dataoff  # Trả về vị trí bắt đầu code signature data để truncate

        offset_cursor += cmdsize

    return None  # Không tìm thấy `LC_CODE_SIGNATURE`

def strip_code_signature(binary_path):
    """
    Xóa hoàn toàn chữ ký code signature từ file Mach-O (64-bit hoặc FAT).
    Sau khi xóa, TrollStore/ldid có thể ký lại sạch từ đầu.
    """
    try:
        with open(binary_path, 'r+b') as f:
            data = f.read(8)
            if len(data) < 4:
                return
            magic = struct.unpack('<I', data[:4])[0]
            truncate_at = None

            if magic == 0xbebafeca or magic == 0xcafebabe:  # FAT Mach-O
                nfat_arch = struct.unpack('>I', data[4:8])[0]
                for i in range(nfat_arch):
                    f.seek(8 + i * 20)
                    arch_data = f.read(20)
                    cputype, cpusubtype, offset, size, align = struct.unpack('>IIIII', arch_data)
                    # Kiểm tra từng slice
                    f.seek(offset)
                    slice_magic = struct.unpack('<I', f.read(4))[0]
                    if slice_magic == 0xfeedfacf:
                        result = _strip_macho_slice_signature(f, offset)
                        if result is not None and (truncate_at is None or result < truncate_at):
                            truncate_at = result
            elif magic == 0xfeedfacf:  # Mach-O 64-bit
                truncate_at = _strip_macho_slice_signature(f, 0)

            # Cắt bỏ phần dữ liệu chữ ký thừa ở cuối file
            if truncate_at is not None:
                f.truncate(truncate_at)
                return True
    except Exception as e:
        print(f"[!] Không thể strip code signature từ {os.path.basename(binary_path)}: {e}")
    return False

def strip_all_signatures(app_path):
    """
    Duyệt toàn bộ .app bundle và xóa code signature của MỌI binary Mach-O.
    Bao gồm: file thực thi chính, tất cả .dylib trong Frameworks/, và .appex trong PlugIns/.
    """
    count = 0
    for root, dirs, files in os.walk(app_path):
        for fname in files:
            fpath = os.path.join(root, fname)
            # Chỉ xử lý file binary (không có phần mở rộng hoặc .dylib/.appex)
            _, ext = os.path.splitext(fname)
            if ext in ('.dylib', '.so', ''):
                try:
                    with open(fpath, 'rb') as f:
                        magic_bytes = f.read(4)
                        if len(magic_bytes) < 4:
                            continue
                        magic = struct.unpack('<I', magic_bytes)[0]
                        if magic in (0xfeedfacf, 0xbebafeca, 0xcafebabe, 0xfeedface):
                            if strip_code_signature(fpath):
                                count += 1
                except Exception:
                    pass
        # Xử lý riêng các file thực thi trong .appex (không có extension)
        for dname in dirs:
            if dname.endswith('.appex') or dname.endswith('.framework'):
                appex_dir = os.path.join(root, dname)
                for sub_f in os.listdir(appex_dir):
                    sub_path = os.path.join(appex_dir, sub_f)
                    if os.path.isfile(sub_path) and '.' not in sub_f:
                        try:
                            with open(sub_path, 'rb') as f:
                                magic_bytes = f.read(4)
                                if len(magic_bytes) < 4:
                                    continue
                                magic = struct.unpack('<I', magic_bytes)[0]
                                if magic in (0xfeedfacf, 0xbebafeca, 0xcafebabe, 0xfeedface):
                                    if strip_code_signature(sub_path):
                                        count += 1
                        except Exception:
                            pass
    return count

def validate_dylib(dylib_path):
    """
    Kiểm tra file dylib có phải là Mach-O MH_DYLIB (filetype 6) hợp lệ không,
    tránh inject nhầm file debug symbols dSYM (filetype 10).
    """
    if not os.path.exists(dylib_path):
        raise FileNotFoundError(f"Không tìm thấy file dylib: {dylib_path}")
        
    with open(dylib_path, 'rb') as f:
        data = f.read(32)
        magic = struct.unpack('<I', data[:4])[0]
        if magic == 0xfeedfacf: # 64-bit Mach-O
            filetype = struct.unpack('<I', data[12:16])[0]
            if filetype != 6: # MH_DYLIB
                raise ValueError(f"File {dylib_path} là Mach-O type {filetype} (MH_DSYM={filetype==10}), KHÔNG PHẢI MH_DYLIB (6)!")
            print(f"[✅] Xác nhận file dylib hợp lệ: {dylib_path} (Mach-O 64-bit MH_DYLIB)")
        elif magic == 0xbebafeca or magic == 0xcafebabe: # FAT Mach-O
            print(f"[✅] Xác nhận file dylib hợp lệ: {dylib_path} (Universal FAT binary)")
        else:
            raise ValueError(f"File {dylib_path} không phải định dạng Mach-O hợp lệ (Magic: {hex(magic)})!")

def patch_dylib_dependency(dylib_path, old_dep, new_dep):
    """
    Thay thế chuỗi dependency trong Mach-O load command (ví dụ đổi CydiaSubstrate sang @rpath/libsubstrate.dylib)
    """
    old_bytes = old_dep.encode('utf-8')
    new_bytes = new_dep.encode('utf-8')
    if len(new_bytes) > len(old_bytes):
        print(f"[!] Cảnh báo: Đường dẫn mới dài hơn đường dẫn cũ!")
        return False
        
    with open(dylib_path, 'r+b') as f:
        content = f.read()
        pos = content.find(old_bytes)
        if pos != -1:
            print(f"[*] Đang vá dependency trong {dylib_path}: {old_dep} -> {new_dep}")
            f.seek(pos)
            # Ghi chuỗi mới và đệm các byte null \x00 cho đủ chiều dài chuỗi cũ
            padded = new_bytes + b'\x00' * (len(old_bytes) - len(new_bytes))
            f.write(padded)
            return True
        else:
            print(f"[*] Không tìm thấy chuỗi dependency {old_dep} (có thể đã được đổi trước đó)")
            return True

def inject_load_dylib(binary_path, dylib_payload_path):
    """
    Chèn load command LC_LOAD_DYLIB (@rpath/BMTikTok.dylib hoặc @executable_path/Frameworks/...)
    vào file thực thi Mach-O 64-bit mà không cần cài optool / insert_dylib.
    """
    with open(binary_path, 'r+b') as f:
        data = f.read()
        magic = struct.unpack('<I', data[:4])[0]
        
        # Kiểm tra Mach-O 64-bit hoặc FAT binary
        if magic == 0xbebafeca or magic == 0xcafebabe: # FAT Mach-O
            nfat_arch = struct.unpack('>I', data[4:8])[0]
            print(f"[*] Phát hiện Universal Mach-O binary ({nfat_arch} architectures)")
            # Tìm arm64 slice
            for i in range(nfat_arch):
                cputype, cpusubtype, offset, size, align = struct.unpack('>IIIII', data[8+i*20:28+i*20])
                if cputype == 0x0100000c: # CPU_TYPE_ARM64
                    print(f"[*] Đang patch ARM64 slice tại offset {hex(offset)}")
                    _patch_macho_slice(f, offset, dylib_payload_path)
                    return True
        elif magic == 0xfeedfacf: # Mach-O 64-bit Little Endian
            _patch_macho_slice(f, 0, dylib_payload_path)
            return True
        else:
            print(f"[-] Định dạng Mach-O không hỗ trợ (Magic: {hex(magic)})")
            return False

def _patch_macho_slice(f, base_offset, dylib_payload_path):
    f.seek(base_offset)
    header = f.read(32)
    magic, cputype, cpusubtype, filetype, ncmds, sizeofcmds, flags, reserved = struct.unpack('<IIIIIIII', header)
    
    # Sử dụng Load Command LC_LOAD_WEAK_DYLIB (0x80000018) giống VibeTok
    # để dyld nạp nhẹ nhàng không bị crash hay strict sandbox abort
    cmd_type = 0x80000018 # LC_LOAD_WEAK_DYLIB
    encoded_path = dylib_payload_path.encode('utf-8') + b'\x00'
    
    # Kiểm tra xem load command đã tồn tại trong binary chưa (tránh chèn trùng)
    f.seek(base_offset + 32)
    existing_cmds = f.read(sizeofcmds)
    if encoded_path in existing_cmds:
        print(f"[*] Load command {dylib_payload_path} đã tồn tại trong binary, bỏ qua.")
        return

    # Padding cho đủ bội số của 8 bytes
    pad_len = (8 - ((24 + len(encoded_path)) % 8)) % 8
    cmd_size = 24 + len(encoded_path) + pad_len
    
    load_cmd_data = struct.pack('<IIIIII', cmd_type, cmd_size, 24, 2, 0, 0) + encoded_path + (b'\x00' * pad_len)
    
    # Kiểm tra xem khoảng trống sau commands có đủ không
    insert_pos = base_offset + 32 + sizeofcmds
    f.seek(insert_pos)
    trailing_bytes = f.read(cmd_size)
    
    # Ghi load command mới vào
    f.seek(insert_pos)
    f.write(load_cmd_data)
    
    # Cập nhật Mach-O header (tăng ncmds lên 1 và sizeofcmds lên cmd_size)
    f.seek(base_offset + 16)
    f.write(struct.pack('<II', ncmds + 1, sizeofcmds + cmd_size))
    print(f"[+] Đã chèn thành công LC_LOAD_WEAK_DYLIB: {dylib_payload_path}")

def repackage_ipa(input_ipa, dylib_path, bundle_path, output_ipa, strip_plugins=False, testflight_mode=False):
    # Validate dylib
    validate_dylib(dylib_path)
    
    print(f"[*] Bắt đầu giải nén IPA: {input_ipa}")
    work_dir = "temp_build_bmtiktok"
    if os.path.exists(work_dir):
        shutil.rmtree(work_dir)
    os.makedirs(work_dir, exist_ok=True)
    
    with zipfile.ZipFile(input_ipa, 'r') as zip_ref:
        zip_ref.extractall(work_dir)
        
    payload_dir = os.path.join(work_dir, "Payload")
    app_dirs = [d for d in os.listdir(payload_dir) if d.endswith(".app")]
    if not app_dirs:
        print("[-] Không tìm thấy thư mục .app trong Payload!")
        return False
        
    app_path = os.path.join(payload_dir, app_dirs[0])
    app_name = app_dirs[0].replace(".app", "")
    main_executable = os.path.join(app_path, app_name)
    frameworks_dir = os.path.join(app_path, "Frameworks")
    os.makedirs(frameworks_dir, exist_ok=True)
    
    print(f"[*] Mục tiêu ứng dụng: {app_path}")
    
    # 1. Chỉ loại bỏ Watch và AppExtensions thừa.
    # GIỮ NGUYÊN PlugIns (đặc biệt WalletAuthExtension.appex) để TikTok không bị lỗi Auth/Login.
    strip_folders = ["Watch", "AppExtensions"]
    if strip_plugins:
        strip_folders.append("PlugIns")
        print("[!] Đang loại bỏ PlugIns theo yêu cầu người dùng...")
    else:
        print("[*] Giữ nguyên PlugIns/ (chứa WalletAuthExtension xử lý đăng nhập & Auth)...")

    for folder in strip_folders:
        folder_path = os.path.join(app_path, folder)
        if os.path.exists(folder_path):
            print(f"[*] Đang loại bỏ {folder}/...")
            shutil.rmtree(folder_path)
            
    # 2. Xóa các chứng chỉ và profile ký cũ
    code_sign_dir = os.path.join(app_path, "_CodeSignature")
    if os.path.exists(code_sign_dir):
        shutil.rmtree(code_sign_dir)
        
    provision_profile = os.path.join(app_path, "embedded.mobileprovision")
    if os.path.exists(provision_profile):
        os.remove(provision_profile)

    # 3. Copy BMTikTok.dylib vào Frameworks
    dest_dylib = os.path.join(frameworks_dir, "BMTikTok.dylib")
    shutil.copy(dylib_path, dest_dylib)
    print(f"[+] Đã sao chép BMTikTok.dylib -> {dest_dylib}")
    
    # 4. Copy libsubstrate.dylib vào Frameworks và vá dependency cho non-jailbreak
    substrate_src = os.path.join(os.path.dirname(__file__), "deps", "libsubstrate.dylib")
    if not os.path.exists(substrate_src):
        substrate_src = "tools/deps/libsubstrate.dylib"
        
    if os.path.exists(substrate_src):
        dest_substrate = os.path.join(frameworks_dir, "libsubstrate.dylib")
        shutil.copy(substrate_src, dest_substrate)
        print(f"[+] Đã sao chép libsubstrate.dylib -> {dest_substrate}")
    else:
        print("[!] Không tìm thấy libsubstrate.dylib trong tools/deps!")
        
    # Vá dependency CydiaSubstrate trong BMTikTok.dylib
    patch_dylib_dependency(dest_dylib, "/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate", "@rpath/libsubstrate.dylib")
    
    # 4.2 Copy sideloadKeychainFix.dylib vào Frameworks (Sửa lỗi Keychain & App Groups cho Sideload)
    keychain_src = os.path.join(os.path.dirname(__file__), "deps", "sideloadKeychainFix.dylib")
    if not os.path.exists(keychain_src):
        keychain_src = "tools/deps/sideloadKeychainFix.dylib"
        
    has_keychain_fix = False
    if os.path.exists(keychain_src):
        dest_keychain = os.path.join(frameworks_dir, "sideloadKeychainFix.dylib")
        shutil.copy(keychain_src, dest_keychain)
        print(f"[+] Đã sao chép sideloadKeychainFix.dylib -> {dest_keychain}")
        has_keychain_fix = True
    else:
        print("[!] Không tìm thấy sideloadKeychainFix.dylib trong tools/deps!")

    # 4.3 Cập nhật Info.plist
    info_plist_path = os.path.join(app_path, "Info.plist")
    if os.path.exists(info_plist_path):
        try:
            with open(info_plist_path, 'rb') as fp:
                plist_obj = plistlib.load(fp)
            plist_obj["UIFileSharingEnabled"] = True
            plist_obj["LSSupportsOpeningDocumentsInPlace"] = True
            
            # Kích hoạt TrollStore Fast-Path: Báo cho TrollStore app đã có pre-applied exploit/pre-signed,
            # tránh TrollStore chạy `ldid -s` đệ quy toàn bộ thư mục app trên thiết bị,
            # gây lỗi ldid.cpp(2817): _assert(): target.sputn(data, writ) == writ (Error 175)
            # do file TikTokCore.framework/TikTokCore quá lớn (~800MB) gây tràn RAM bộ đệm std::stringbuf của ldid
            plist_obj["TSPreAppliedExploitType"] = 2
            plist_obj["TSBundlePreSigned"] = True

            if testflight_mode:
                print("[+] Đang áp dụng cấu hình TestFlight (CHANNEL_NAME=TestFlight_online, SSAppID=1233)...")
                plist_obj["CHANNEL_NAME"] = "TestFlight_online"
                plist_obj["SSAppID"] = "1233"
                plist_obj["beta-reports-active"] = True

            with open(info_plist_path, 'wb') as fp:
                plistlib.dump(plist_obj, fp)
            print("[+] Đã cập nhật Info.plist (kích hoạt UIFileSharingEnabled + TrollStore Fast-Path)")
        except Exception as e:
            print(f"[!] Cảnh báo không thể sửa Info.plist: {e}")
        
    # 5. Copy BMTikTok.bundle vào thư mục ứng dụng
    if os.path.exists(bundle_path):
        dest_bundle = os.path.join(app_path, "BMTikTok.bundle")
        if os.path.exists(dest_bundle):
            shutil.rmtree(dest_bundle)
        shutil.copytree(bundle_path, dest_bundle)
        print(f"[+] Đã sao chép BMTikTok.bundle -> {dest_bundle}")
        
    # 5.5 Strip code signature trước khi chèn load dylib (tránh hỏng bảng load command Mach-O)
    print(f"[*] Đang strip code signature từ file thực thi chính: {main_executable}")
    strip_code_signature(main_executable)

    # 6. Patch LC_LOAD_WEAK_DYLIB vào file thực thi
    print(f"[*] Đang chèn load dylib vào file thực thi: {main_executable}")
    inject_load_dylib(main_executable, "@rpath/BMTikTok.dylib")
    if has_keychain_fix:
        inject_load_dylib(main_executable, "@rpath/sideloadKeychainFix.dylib")

    # 7. Ký lại toàn bộ Frameworks, Dylibs, PlugIns và Executable chính bằng ldid
    if shutil.which("ldid"):
        print("[*] Đang ký ldid -S cho toàn bộ Frameworks & Dylibs...")
        for root, dirs, files in os.walk(frameworks_dir):
            for fname in files:
                fpath = os.path.join(root, fname)
                _, ext = os.path.splitext(fname)
                if ext in ('.dylib', '.so', ''):
                    try:
                        with open(fpath, 'rb') as bf:
                            mb = bf.read(4)
                        if len(mb) == 4:
                            magic = struct.unpack('<I', mb)[0]
                            if magic in (0xfeedfacf, 0xbebafeca, 0xcafebabe, 0xfeedface):
                                strip_code_signature(fpath)
                                subprocess.run(["ldid", "-S", fpath], capture_output=True)
                    except Exception:
                        pass

        # Ký PlugIns nếu còn
        plugins_dir = os.path.join(app_path, "PlugIns")
        if os.path.exists(plugins_dir):
            print("[*] Đang ký ldid -S cho PlugIns...")
            for root, dirs, files in os.walk(plugins_dir):
                for fname in files:
                    fpath = os.path.join(root, fname)
                    if '.' not in fname:
                        try:
                            with open(fpath, 'rb') as bf:
                                mb = bf.read(4)
                            if len(mb) == 4:
                                magic = struct.unpack('<I', mb)[0]
                                if magic in (0xfeedfacf, 0xbebafeca, 0xcafebabe, 0xfeedface):
                                    strip_code_signature(fpath)
                                    subprocess.run(["ldid", "-S", fpath], capture_output=True)
                        except Exception:
                            pass

        main_ent = os.path.join(app_path, "archived-expanded-entitlements.xcent")
        cmd = ["ldid", f"-S{main_ent}" if os.path.exists(main_ent) else "-S", main_executable]
        print(f"[*] Đang ký ldid cho {main_executable}...")
        try:
            res = subprocess.run(cmd, capture_output=True, text=True)
            if res.returncode == 0:
                print(f"[+] Đã ký ldid thành công cho: {main_executable}")
            else:
                print(f"[!] Cảnh báo ldid: {res.stderr.strip()}")
        except Exception as e:
            print(f"[!] Lỗi khi chạy ldid: {e}")

    # 8. Đóng gói lại thành file IPA mới
    print(f"[*] Đang nén thành phẩm IPA: {output_ipa}")
    with zipfile.ZipFile(output_ipa, 'w', zipfile.ZIP_DEFLATED) as zip_out:
        for root, dirs, files in os.walk(work_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, work_dir)
                zip_out.write(file_path, arcname)
                
    # Dọn dẹp
    shutil.rmtree(work_dir)
    print(f"[✅] THÀNH CÔNG! File IPA hoàn thiện tại: {output_ipa}")
    return True

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="BMTikTok IPA Injector")
    parser.add_argument("-i", "--input", required=True, help="Đường dẫn file IPA TikTok gốc")
    parser.add_argument("-d", "--dylib", required=True, help="Đường dẫn file BMTikTok.dylib đã build")
    parser.add_argument("-b", "--bundle", required=True, help="Đường dẫn BMTikTok.bundle")
    parser.add_argument("-o", "--output", default="BMTikTok_Modded.ipa", help="Đường dẫn file IPA đầu ra")
    parser.add_argument("--strip-plugins", action="store_true", help="Loại bỏ PlugIns/ (chỉ dùng nếu bị giới hạn 3 App ID của Apple ID miễn phí)")
    parser.add_argument("--testflight", action="store_true", help="Kích hoạt TestFlight mode trong Info.plist để nới lỏng kiểm tra App Store receipt")
    
    args = parser.parse_args()
    repackage_ipa(args.input, args.dylib, args.bundle, args.output, strip_plugins=args.strip_plugins, testflight_mode=args.testflight)
