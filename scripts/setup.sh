#!/bin/bash

# ==============================================
# Kaizen 3D Printing - Setup Script
# ==============================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
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

print_header "Kaizen 3D Printing - Setup"

# ==============================================
# Step 1: Check PHP Version
# ==============================================
print_info "Checking PHP version..."
PHP_VERSION=$(php -r 'echo PHP_VERSION;')
PHP_MAJOR=$(echo $PHP_VERSION | cut -d. -f1)
PHP_MINOR=$(echo $PHP_VERSION | cut -d. -f2)

if [ "$PHP_MAJOR" -lt 8 ] || ([ "$PHP_MAJOR" -eq 8 ] && [ "$PHP_MINOR" -lt 1 ]); then
    print_error "PHP 8.1 or higher is required. Current version: $PHP_VERSION"
    exit 1
fi
print_success "PHP $PHP_VERSION detected"

# ==============================================
# Step 2: Check Composer
# ==============================================
print_info "Checking for Composer..."
if ! command -v composer &> /dev/null; then
    print_warning "Composer not found. Installing Composer..."

    # Download and install Composer
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php composer-setup.php --quiet
    rm composer-setup.php
    mv composer.phar /usr/local/bin/composer 2>/dev/null || sudo mv composer.phar /usr/local/bin/composer

    print_success "Composer installed successfully"
else
    print_success "Composer found: $(composer --version | head -n 1)"
fi

# ==============================================
# Step 3: Install Backend Dependencies
# ==============================================
print_header "Installing Backend Dependencies"
cd backend

if [ ! -f "composer.json" ]; then
    print_error "composer.json not found in backend directory"
    exit 1
fi

print_info "Running composer install..."
composer install --no-interaction --prefer-dist

if [ $? -eq 0 ]; then
    print_success "Backend dependencies installed successfully"
else
    print_error "Failed to install backend dependencies"
    exit 1
fi

cd ..

# ==============================================
# Step 4: Create .env file
# ==============================================
print_header "Environment Configuration"

if [ ! -f "backend/.env" ]; then
    print_info "Creating .env file from .env.example..."
    cp backend/.env.example backend/.env

    # Generate JWT Secret
    JWT_SECRET=$(php -r "echo bin2hex(random_bytes(32));")

    # Update JWT_SECRET in .env
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/JWT_SECRET=.*/JWT_SECRET=$JWT_SECRET/" backend/.env
    else
        # Linux
        sed -i "s/JWT_SECRET=.*/JWT_SECRET=$JWT_SECRET/" backend/.env
    fi

    print_success ".env file created with random JWT_SECRET"
    print_warning "Please edit backend/.env to configure database and other settings"

    # Prompt for database configuration
    read -p "$(echo -e ${BLUE}Would you like to configure database now? [y/N]:${NC} )" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Database Host [localhost]: " DB_HOST
        DB_HOST=${DB_HOST:-localhost}

        read -p "Database Name [kaizen_3d]: " DB_NAME
        DB_NAME=${DB_NAME:-kaizen_3d}

        read -p "Database Username [root]: " DB_USER
        DB_USER=${DB_USER:-root}

        read -sp "Database Password: " DB_PASS
        echo

        # Update .env file
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/DB_HOST=.*/DB_HOST=$DB_HOST/" backend/.env
            sed -i '' "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" backend/.env
            sed -i '' "s/DB_USERNAME=.*/DB_USERNAME=$DB_USER/" backend/.env
            sed -i '' "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" backend/.env
        else
            sed -i "s/DB_HOST=.*/DB_HOST=$DB_HOST/" backend/.env
            sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" backend/.env
            sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USER/" backend/.env
            sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" backend/.env
        fi

        print_success "Database configuration saved"
    fi
else
    print_warning "backend/.env already exists. Skipping..."
fi

# ==============================================
# Step 5: Create Storage Directories
# ==============================================
print_header "Creating Storage Directories"

mkdir -p backend/storage/uploads/{2024,2025}/{01..12}
mkdir -p backend/storage/logs
mkdir -p backend/storage/cache

chmod -R 755 backend/storage

print_success "Storage directories created with proper permissions"

# ==============================================
# Step 6: Database Setup
# ==============================================
print_header "Database Setup"

# Load .env file
if [ -f backend/.env ]; then
    export $(cat backend/.env | grep -v '^#' | xargs)
fi

read -p "$(echo -e ${BLUE}Would you like to create the database now? [y/N]:${NC} )" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_info "Creating database: $DB_DATABASE"

    # Try to create database
    mysql -h "$DB_HOST" -u "$DB_USERNAME" -p"$DB_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS $DB_DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null

    if [ $? -eq 0 ]; then
        print_success "Database created successfully"

        # Run migrations
        read -p "$(echo -e ${BLUE}Would you like to run migrations now? [y/N]:${NC} )" -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Running migrations..."

            if [ -f "backend/database/schema.sql" ]; then
                mysql -h "$DB_HOST" -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_DATABASE" < backend/database/schema.sql
                print_success "Migrations completed"
            else
                print_warning "No schema.sql found. You'll need to run migrations manually"
            fi
        fi
    else
        print_error "Failed to create database. Please create it manually:"
        echo "  mysql -u $DB_USERNAME -p"
        echo "  CREATE DATABASE $DB_DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    fi
fi

# ==============================================
# Step 7: Frontend Setup (Optional)
# ==============================================
print_header "Frontend Setup"

if command -v npm &> /dev/null; then
    read -p "$(echo -e ${BLUE}Would you like to install frontend dependencies? [y/N]:${NC} )" -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cd frontend
        print_info "Running npm install..."
        npm install
        print_success "Frontend dependencies installed"
        cd ..
    fi
else
    print_warning "npm not found. Skipping frontend setup."
    print_info "You can use CDN links in your HTML files instead"
fi

# ==============================================
# Step 8: Create Test Admin User
# ==============================================
print_header "Admin User Setup"

read -p "$(echo -e ${BLUE}Would you like to create an admin user? [y/N]:${NC} )" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Admin Email: " ADMIN_EMAIL
    read -sp "Admin Password: " ADMIN_PASSWORD
    echo

    # Hash password
    HASHED_PASSWORD=$(php -r "echo password_hash('$ADMIN_PASSWORD', PASSWORD_BCRYPT);")

    # Insert admin user
    mysql -h "$DB_HOST" -u "$DB_USERNAME" -p"$DB_PASSWORD" "$DB_DATABASE" -e "
        INSERT INTO users (name, email, password_hash, role, status)
        VALUES ('Admin', '$ADMIN_EMAIL', '$HASHED_PASSWORD', 'admin', 'active');
    " 2>/dev/null

    if [ $? -eq 0 ]; then
        print_success "Admin user created successfully"
    else
        print_warning "Could not create admin user. You may need to do this manually."
    fi
fi

# ==============================================
# Step 9: Test Backend Server
# ==============================================
print_header "Testing Setup"

print_info "Starting PHP built-in server for testing..."
print_info "Access the API at: http://localhost:8000/api/health"
print_warning "Press Ctrl+C to stop the server"

read -p "$(echo -e ${BLUE}Would you like to start the test server now? [y/N]:${NC} )" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd backend
    php -S localhost:8000 -t public
else
    print_info "You can start the server manually with:"
    echo "  cd backend && php -S localhost:8000 -t public"
fi

# ==============================================
# Final Summary
# ==============================================
print_header "Setup Complete!"

echo ""
print_success "Kaizen 3D Printing has been set up successfully!"
echo ""
print_info "Next steps:"
echo "  1. Edit backend/.env to configure your settings"
echo "  2. Start the backend server:"
echo "     cd backend && php -S localhost:8000 -t public"
echo "  3. Open the frontend:"
echo "     cd frontend && npx serve public -p 3000"
echo "  4. Read the documentation in docs/ folder"
echo ""
print_info "Quick links:"
echo "  - Backend API: http://localhost:8000"
echo "  - Frontend: http://localhost:3000"
echo "  - Architecture: ARCHITECTURE.md"
echo "  - Quick Start: QUICKSTART.md"
echo "  - API Docs: docs/API.md"
echo ""
print_success "Happy coding! 🚀"
echo ""
