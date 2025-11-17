#!/bin/bash

# ==============================================
# Kaizen 3D Printing - Package for Deployment
# ==============================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_header() {
    echo ""
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}================================${NC}"
    echo ""
}

# Check if running from project root
if [ ! -f "README.md" ] || [ ! -d "backend" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

print_header "Kaizen 3D - Package for Deployment"

# Create temp directory
TEMP_DIR="kaizen_deploy_temp"
ZIP_NAME="kaizen_web_deploy_$(date +%Y%m%d_%H%M%S).zip"

print_info "Creating temporary directory..."
rm -rf $TEMP_DIR
mkdir -p $TEMP_DIR

# Copy files
print_info "Copying project files..."
rsync -av \
    --exclude='.git' \
    --exclude='node_modules' \
    --exclude='backend/vendor' \
    --exclude='backend/.env' \
    --exclude='*.log' \
    --exclude='.DS_Store' \
    --exclude='*.tmp' \
    --exclude='backend/storage/uploads/*' \
    --exclude='backend/storage/logs/*' \
    --exclude='backend/storage/cache/*' \
    ./ $TEMP_DIR/

print_success "Files copied"

# Install Composer dependencies
print_info "Installing Composer dependencies (production mode)..."
cd $TEMP_DIR/backend

if command -v composer &> /dev/null; then
    composer install --no-dev --optimize-autoloader --no-interaction
    print_success "Composer dependencies installed"
else
    print_warning "Composer not found. Please install dependencies manually on the server."
fi

cd ../..

# Create .gitkeep files for empty directories
print_info "Creating .gitkeep files..."
touch $TEMP_DIR/backend/storage/uploads/.gitkeep
touch $TEMP_DIR/backend/storage/logs/.gitkeep
touch $TEMP_DIR/backend/storage/cache/.gitkeep
print_success ".gitkeep files created"

# Create deployment instructions file
print_info "Creating deployment checklist..."
cat > $TEMP_DIR/DEPLOY_CHECKLIST.txt << 'EOF'
╔════════════════════════════════════════════════════════╗
║     Kaizen 3D Printing - Deployment Checklist         ║
╚════════════════════════════════════════════════════════╝

📦 فایل‌ها آماده دیپلوی است!

⚠️  قبل از آپلود:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

□ اطلاعات دیتابیس cPanel را آماده کنید:
  - Database name
  - Database username
  - Database password

□ توکن بات تلگرام را آماده کنید (اگر دارید)

□ یک JWT_SECRET تصادفی تولید کنید:
  php -r "echo bin2hex(random_bytes(32));"


🚀 مراحل دیپلوی:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. آپلود فایل ZIP به cPanel:
   ✓ File Manager → Upload
   ✓ Extract کنید

2. ایجاد دیتابیس:
   ✓ MySQL Databases → Create Database
   ✓ Create User → Add User to Database
   ✓ phpMyAdmin → Import: backend/database/schema.sql

3. تنظیم .env:
   ✓ backend/.env.example را به .env کپی کنید
   ✓ اطلاعات دیتابیس را وارد کنید
   ✓ JWT_SECRET را تنظیم کنید
   ✓ APP_ENV=production و APP_DEBUG=false

4. تنظیم Permissions:
   ✓ backend/.env → 644
   ✓ backend/storage → 755 (و زیرپوشه‌ها)

5. تنظیم .htaccess:
   ✓ فایل‌های .htaccess را بررسی کنید
   ✓ در صورت نیاز، مطابق راهنما تنظیم کنید

6. تست:
   ✓ https://yourdomain.com/api/health
   ✓ https://yourdomain.com/api/test/db
   ✓ https://yourdomain.com


📚 مستندات کامل:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

فایل DEPLOY_GUIDE.md را حتما مطالعه کنید!


🆘 در صورت بروز مشکل:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

• لاگ‌های خطا را چک کنید (cPanel → Error Log)
• مستندات را بخوانید: docs/DEPLOYMENT.md
• راهنمای عیب‌یابی در DEPLOY_GUIDE.md


✅ بعد از دیپلوی موفق:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

□ SSL Certificate نصب کنید (Let's Encrypt رایگان)
□ Backup منظم راه‌اندازی کنید
□ بات تلگرام را متصل کنید
□ ماژول‌های بعدی را توسعه دهید

موفق باشید! 🎉
EOF

print_success "Deployment checklist created"

# Create ZIP file
print_info "Creating ZIP archive..."
cd $TEMP_DIR
zip -r ../$ZIP_NAME . -q
cd ..

print_success "ZIP file created: $ZIP_NAME"

# Show file size
FILE_SIZE=$(du -h $ZIP_NAME | cut -f1)
print_info "File size: $FILE_SIZE"

# Clean up
print_info "Cleaning up..."
rm -rf $TEMP_DIR
print_success "Temporary files removed"

# Summary
print_header "Package Complete!"

echo ""
echo -e "${GREEN}📦 Package ready for deployment:${NC}"
echo -e "   ${BLUE}$ZIP_NAME${NC}"
echo -e "   ${YELLOW}Size: $FILE_SIZE${NC}"
echo ""
echo -e "${GREEN}📝 Next steps:${NC}"
echo "   1. Upload $ZIP_NAME to your cPanel"
echo "   2. Extract it using File Manager"
echo "   3. Follow DEPLOY_CHECKLIST.txt"
echo "   4. Read DEPLOY_GUIDE.md for detailed instructions"
echo ""
echo -e "${BLUE}📖 Important files in the package:${NC}"
echo "   • DEPLOY_GUIDE.md - راهنمای کامل دیپلوی"
echo "   • DEPLOY_CHECKLIST.txt - چک‌لیست گام به گام"
echo "   • backend/database/schema.sql - اسکیمای دیتابیس"
echo "   • backend/.env.example - نمونه تنظیمات"
echo ""
echo -e "${GREEN}✨ Ready to deploy!${NC}"
echo ""
