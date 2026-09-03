# Đặt tên file đầu ra
$outputFile = "project_full_export.txt"

# Xóa file cũ nếu tồn tại
if (Test-Path $outputFile) { Remove-Item $outputFile }

# Danh sách thư mục cần bỏ qua (không lấy nội dung)
$excludeDirs = @(
    "build",
    ".dart_tool",
    ".git",
    "windows",
    "linux",
    "macos",
    "ios",
    "android",
    "web",
    "node_modules",
    ".idea",
    ".vscode",
    "pub-cache"
)

# Lấy tất cả file (trừ những file trong thư mục bị loại)
Get-ChildItem -Recurse -File | Where-Object {
    $path = $_.FullName
    $exclude = $false
    foreach ($dir in $excludeDirs) {
        if ($path -match "\\$dir\\") {
            $exclude = $true
            break
        }
    }
    -not $exclude
} | ForEach-Object {
    # Đường dẫn tương đối (so với thư mục hiện tại)
    $relativePath = $_.FullName.Substring((Get-Location).Path.Length + 1)
    
    # Ghi tiêu đề file
    "`n" + "="*80 >> $outputFile
    "FILE: $relativePath" >> $outputFile
    "="*80 >> $outputFile
    
    # Ghi nội dung file (xử lý lỗi nếu không đọc được)
    try {
        Get-Content $_.FullName -ErrorAction Stop >> $outputFile
    } catch {
        "[Không thể đọc nội dung file này]" >> $outputFile
    }
}

Write-Host "✅ Xuất thành công! Xem file: $outputFile"
Write-Host "Tổng số file đã xuất: $((Get-ChildItem -Recurse -File | Where-Object { ... }).Count)" # (Không tính chính xác ở đây, có thể bỏ qua)