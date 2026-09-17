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
# Mach-O Architecture & Codesign Utilities
# Bảo đảm các binary là ARM64 hợp lệ và có segment LC_CODE_SIGNATURE,
# giúp zsign / iSigner ký thành công không bị lỗi "Can't find CodeSignature segment!"
# ═══════════════════════════════════════════════════════════════

LC_CODE_SIGNATURE = 0x1d

def thin_to_arm64(filepath):
    """
    Nếu file là Universal/FAT Mach-O, trích xuất slice ARM64 thành file Mach-O 64-bit đơn lẻ.
    Giúp tránh lỗi FAT truncation và bảo toàn tính toàn vẹn chữ ký cho ARM64.
    """
    if not os.path.isfile(filepath):
        return False
    try:
        with open(filepath, "rb") as f:
            magic = f.read(4)
            if len(magic) < 4:
                return False
            magic_val = struct.unpack("<I", magic)[0]
            if magic_val == 0xfeedfacf:  # Đã là Mach-O 64-bit đơn
                return True
            if magic_val in (0xbebafeca, 0xcafebabe):  # FAT Mach-O
                f.seek(4)
                nfat_arch = struct.unpack(">I", f.read(4))[0]
                arm64_slice = None
                for i in range(nfat_arch):
                    f.seek(8 + i * 20)
                    cputype, cpusubtype, offset, size, align = struct.unpack(">IIIII", f.read(20))
                    if cputype == 0x0100000c:  # ARM64
                        f.seek(offset)
                        arm64_slice = f.read(size)
                        break
                if arm64_slice:
                    with open(filepath, "wb") as f_out:
                        f_out.write(arm64_slice)
                    print(f"[+] Đã trích xuất slice ARM64 cho {os.path.basename(filepath)} ({len(arm64_slice)} bytes)")
                    return True
                else:
                    print(f"[!] Không tìm thấy slice ARM64 trong FAT binary {filepath}!")
    except Exception as e:
        print(f"[!] Lỗi khi thin ARM64 {filepath}: {e}")
    return False

def has_code_signature(binary_path):
    """Kiểm tra xem binary Mach-O (hoặc slice ARM64) đã có LC_CODE_SIGNATURE hay chưa."""
    try:
        with open(binary_path, 'rb') as f:
            magic = f.read(4)
            if len(magic) < 4:
                return False
            mval = struct.unpack('<I', magic)[0]
            base_offset = 0
            if mval in (0xbebafeca, 0xcafebabe):  # FAT
                f.seek(4)
                nfat = struct.unpack('>I', f.read(4))[0]
                for i in range(nfat):
                    f.seek(8 + i * 20)
                    cputype, _, offset, _, _ = struct.unpack('>IIIII', f.read(20))
                    if cputype == 0x0100000c:  # ARM64
                        base_offset = offset
                        break
            f.seek(base_offset)
            hdr = f.read(32)
            if len(hdr) < 32:
                return False
            _, _, _, _, ncmds, sizeofcmds, _, _ = struct.unpack('<IIIIIIII', hdr)
            offset_cursor = base_offset + 32
            for _ in range(ncmds):
                f.seek(offset_cursor)
                cmd_hdr = f.read(8)
                if len(cmd_hdr) < 8:
                    break
                cmd, cmdsize = struct.unpack('<II', cmd_hdr)
                if cmd == LC_CODE_SIGNATURE:
                    return True
                offset_cursor += cmdsize
    except Exception:
        pass
    return False

def sign_binary(binary_path, entitlements_path=None):
    """
    Ký ad-hoc cho binary Mach-O bằng `codesign` (trên macOS) hoặc `ldid` (trên Linux/iOS).
    Bảo đảm binary có LC_CODE_SIGNATURE hợp lệ, giúp zsign/iSigner không bị lỗi:
    'Can't find CodeSignature segment!'.
    """
    if not os.path.isfile(binary_path):
        return False
    # 1. Thử codesign trước (chuẩn Apple trên macOS)
    if shutil.which("codesign"):
        cmd = ["codesign", "-f", "-s", "-"]
        if entitlements_path and os.path.exists(entitlements_path):
            cmd.extend(["--entitlements", entitlements_path])
        cmd.append(binary_path)
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode == 0:
            return True
    # 2. Fallback sang ldid
    if shutil.which("ldid"):
        cmd = ["ldid"]
        if entitlements_path and os.path.exists(entitlements_path):
            cmd.append(f"-S{entitlements_path}")
        else:
            cmd.append("-S")
        cmd.append(binary_path)
        res = subprocess.run(cmd, capture_output=True, text=True)
        if res.returncode == 0:
            return True
    return False

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
    thin_to_arm64(dest_dylib)
    sign_binary(dest_dylib)
    print(f"[+] Đã sao chép, thin ARM64 và ký BMTikTok.dylib -> {dest_dylib}")
    
    # 4. Copy libsubstrate.dylib vào Frameworks và vá dependency cho non-jailbreak
    substrate_src = os.path.join(os.path.dirname(__file__), "deps", "libsubstrate.dylib")
    if not os.path.exists(substrate_src):
        substrate_src = "tools/deps/libsubstrate.dylib"
        
    if os.path.exists(substrate_src):
        dest_substrate = os.path.join(frameworks_dir, "libsubstrate.dylib")
        shutil.copy(substrate_src, dest_substrate)
        thin_to_arm64(dest_substrate)
        sign_binary(dest_substrate)
        print(f"[+] Đã sao chép, thin ARM64 và ký libsubstrate.dylib -> {dest_substrate}")
    else:
        print("[!] Không tìm thấy libsubstrate.dylib trong tools/deps!")
        
    # Vá dependency CydiaSubstrate trong BMTikTok.dylib
    patch_dylib_dependency(dest_dylib, "/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate", "@rpath/libsubstrate.dylib")
    sign_binary(dest_dylib)
    
    # 4.2 Copy sideloadKeychainFix.dylib vào Frameworks (Sửa lỗi Keychain & App Groups cho Sideload)
    keychain_src = os.path.join(os.path.dirname(__file__), "deps", "sideloadKeychainFix.dylib")
    if not os.path.exists(keychain_src):
        keychain_src = "tools/deps/sideloadKeychainFix.dylib"
        
    has_keychain_fix = False
    if os.path.exists(keychain_src):
        dest_keychain = os.path.join(frameworks_dir, "sideloadKeychainFix.dylib")
        shutil.copy(keychain_src, dest_keychain)
        thin_to_arm64(dest_keychain)
        sign_binary(dest_keychain)
        print(f"[+] Đã sao chép, thin ARM64 và ký sideloadKeychainFix.dylib -> {dest_keychain}")
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
        
    # 6. Patch LC_LOAD_WEAK_DYLIB vào file thực thi
    print(f"[*] Đang chèn load dylib vào file thực thi: {main_executable}")
    inject_load_dylib(main_executable, "@rpath/BMTikTok.dylib")
    if has_keychain_fix:
        inject_load_dylib(main_executable, "@rpath/sideloadKeychainFix.dylib")

    # 7. Ký lại file thực thi chính sau khi chèn load commands
    main_ent = os.path.join(app_path, "archived-expanded-entitlements.xcent")
    print(f"[*] Đang ký lại ad-hoc cho {main_executable}...")
    if sign_binary(main_executable, main_ent if os.path.exists(main_ent) else None):
        print(f"[+] Đã ký thành công cho {main_executable}")
    else:
        print(f"[!] Cảnh báo: Không thể ký {main_executable}")

    # Kiểm tra tính hợp lệ của tất cả các binary trước khi đóng gói
    print("[*] Đang kiểm tra tính toàn vẹn chữ ký của các thành phần...")
    binaries_to_check = [main_executable, dest_dylib, dest_substrate]
    if has_keychain_fix:
        binaries_to_check.append(dest_keychain)
    for b in binaries_to_check:
        status = "OK (Có LC_CODE_SIGNATURE)" if has_code_signature(b) else "CẢNH BÁO: Thiếu LC_CODE_SIGNATURE!"
        print(f"    - {os.path.basename(b)}: {status}")

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
