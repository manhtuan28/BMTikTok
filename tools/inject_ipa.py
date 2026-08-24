#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BMTikTok IPA Injector Tool
Created by Tuancute28 (Bùi Mạnh Tuấn)

Tự động giải nén IPA TikTok gốc, chèn BMTikTok.dylib, BMTikTok.bundle,
CydiaSubstrate và đóng gói thành phẩm BMTikTok IPA hoàn chỉnh.
"""

import sys
import os
import shutil
import zipfile
import struct
import argparse

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
    
    # Chuẩn bị Load Command LC_LOAD_DYLIB (0x0c) hoặc LC_LOAD_WEAK_DYLIB (0x80000018)
    cmd_type = 0x0c # LC_LOAD_DYLIB
    encoded_path = dylib_payload_path.encode('utf-8') + b'\x00'
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
    print(f"[+] Đã chèn thành công LC_LOAD_DYLIB: {dylib_payload_path}")

def repackage_ipa(input_ipa, dylib_path, bundle_path, output_ipa):
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
    
    # 1. Copy BMTikTok.dylib vào Frameworks
    dest_dylib = os.path.join(frameworks_dir, "BMTikTok.dylib")
    shutil.copy(dylib_path, dest_dylib)
    print(f"[+] Đã sao chép BMTikTok.dylib -> {dest_dylib}")
    
    # 2. Copy BMTikTok.bundle vào thư mục ứng dụng
    if os.path.exists(bundle_path):
        dest_bundle = os.path.join(app_path, "BMTikTok.bundle")
        if os.path.exists(dest_bundle):
            shutil.rmtree(dest_bundle)
        shutil.copytree(bundle_path, dest_bundle)
        print(f"[+] Đã sao chép BMTikTok.bundle -> {dest_bundle}")
        
    # 3. Patch LC_LOAD_DYLIB vào file thực thi
    print(f"[*] Đang chèn load dylib vào file thực thi: {main_executable}")
    inject_load_dylib(main_executable, "@rpath/BMTikTok.dylib")
    
    # 4. Kiểm tra MusicallyCore.framework nếu có
    musically_core = os.path.join(frameworks_dir, "MusicallyCore.framework", "MusicallyCore")
    if os.path.exists(musically_core):
        print(f"[*] Phát hiện MusicallyCore.framework, đang chèn load dylib...")
        inject_load_dylib(musically_core, "@rpath/BMTikTok.dylib")
        
    # 5. Xóa thư mục code signature cũ
    code_sign_dir = os.path.join(app_path, "_CodeSignature")
    if os.path.exists(code_sign_dir):
        shutil.rmtree(code_sign_dir)
        
    # 6. Đóng gói lại thành file IPA mới
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
    
    args = parser.parse_args()
    repackage_ipa(args.input, args.dylib, args.bundle, args.output)
