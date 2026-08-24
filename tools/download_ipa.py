#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
BMTikTok IPA Downloader Tool
Created by Tuancute28 (Bùi Mạnh Tuấn)

Tự động tải file IPA từ Google Drive (xử lý xác thực dung lượng lớn),
hoặc từ bất kỳ đường link trực tiếp (Direct URL) nào mà không cần cài thêm thư viện ngoài.
"""

import sys
import os
import re
import urllib.request
import urllib.parse
import http.cookiejar
import argparse

def download_file(url, output_path):
    print(f"[*] Bắt đầu tải IPA từ URL: {url}")
    
    # 1. Kiểm tra xem có phải link Google Drive không
    gdrive_match = re.search(r'/d/([a-zA-Z0-9_-]+)', url) or re.search(r'id=([a-zA-Z0-9_-]+)', url)
    if gdrive_match and ("drive.google.com" in url or "drive.usercontent.google.com" in url):
        file_id = gdrive_match.group(1)
        print(f"[*] Phát hiện liên kết Google Drive, File ID: {file_id}")
        return download_from_gdrive(file_id, output_path)
    else:
        return download_direct(url, output_path)

def download_from_gdrive(file_id, output_path):
    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
    opener.addheaders = [('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36')]
    
    init_url = f"https://drive.google.com/uc?id={file_id}&export=download"
    response = opener.open(init_url)
    
    # Nếu tải trực tiếp được luôn
    if response.headers.get('Content-Disposition') or response.headers.get('Content-Type') == 'application/octet-stream':
        return _stream_to_file(response, output_path)
        
    html = response.read().decode('utf-8', 'ignore')
    
    # Trích xuất form xác nhận tải file lớn từ Google Drive
    form_match = re.search(r'<form[^>]*action=\"([^\"]+)\"[^>]*>(.*?)</form>', html, re.DOTALL)
    if form_match:
        action = form_match.group(1)
        form_content = form_match.group(2)
        params = {}
        for name, value in re.findall(r'<input[^>]*name=\"([^\"]+)\"[^>]*value=\"([^\"]*)\"', form_content):
            params[name] = value
        query = urllib.parse.urlencode(params)
        final_url = f"{action}?{query}"
        print(f"[*] Đã tạo liên kết vượt xác thực Google Drive thành công!")
        final_req = urllib.request.Request(final_url)
        res = opener.open(final_req)
        return _stream_to_file(res, output_path)
    else:
        # Thử đường dẫn fallback confirm=t
        fallback_url = f"https://drive.google.com/uc?id={file_id}&export=download&confirm=t"
        res = opener.open(fallback_url)
        return _stream_to_file(res, output_path)

def download_direct(url, output_path):
    opener = urllib.request.build_opener()
    opener.addheaders = [('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)')]
    response = opener.open(url)
    return _stream_to_file(response, output_path)

def _stream_to_file(response, output_path):
    total_size = int(response.headers.get('Content-Length', 0))
    if total_size > 0:
        print(f"[*] Dung lượng file: {total_size / (1024 * 1024):.2f} MB")
    else:
        print(f"[*] Đang tải luồng dữ liệu...")
        
    downloaded = 0
    with open(output_path, 'wb') as f:
        while True:
            chunk = response.read(1024 * 1024) # 1 MB chunks
            if not chunk:
                break
            f.write(chunk)
            downloaded += len(chunk)
            if total_size > 0:
                percent = (downloaded / total_size) * 100
                sys.stdout.write(f"\r[+] Đã tải: {downloaded / (1024 * 1024):.1f} / {total_size / (1024 * 1024):.1f} MB ({percent:.1f}%)")
            else:
                sys.stdout.write(f"\r[+] Đã tải: {downloaded / (1024 * 1024):.1f} MB")
            sys.stdout.flush()
            
    print(f"\n[✅] Tải hoàn tất! Đã lưu tại: {output_path} (Kích thước: {os.path.getsize(output_path) / (1024 * 1024):.2f} MB)")
    return True

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="BMTikTok IPA Downloader")
    parser.add_argument("-u", "--url", required=True, help="URL file IPA (Google Drive hoặc Direct Link)")
    parser.add_argument("-o", "--output", default="input_tiktok.ipa", help="Tên file đầu ra")
    
    args = parser.parse_args()
    success = download_file(args.url, args.output)
    if not success:
        sys.exit(1)
