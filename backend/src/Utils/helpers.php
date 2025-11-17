<?php

/**
 * Global helper functions
 */

if (!function_exists('env')) {
    /**
     * Get environment variable
     */
    function env(string $key, $default = null)
    {
        return $_ENV[$key] ?? $default;
    }
}

if (!function_exists('config')) {
    /**
     * Get configuration value
     */
    function config(string $key, $default = null)
    {
        // For now, just return from env
        // Later can be extended to read from config files
        return env($key, $default);
    }
}

if (!function_exists('now')) {
    /**
     * Get current timestamp
     */
    function now(): string
    {
        return date('Y-m-d H:i:s');
    }
}

if (!function_exists('generateToken')) {
    /**
     * Generate random token
     */
    function generateToken(int $length = 32): string
    {
        return bin2hex(random_bytes($length));
    }
}

if (!function_exists('hashPassword')) {
    /**
     * Hash password using bcrypt
     */
    function hashPassword(string $password): string
    {
        return password_hash($password, PASSWORD_BCRYPT, [
            'cost' => (int) env('PASSWORD_HASH_COST', 12)
        ]);
    }
}

if (!function_exists('verifyPassword')) {
    /**
     * Verify password against hash
     */
    function verifyPassword(string $password, string $hash): bool
    {
        return password_verify($password, $hash);
    }
}

if (!function_exists('sanitizeInput')) {
    /**
     * Sanitize user input
     */
    function sanitizeInput($input)
    {
        if (is_array($input)) {
            return array_map('sanitizeInput', $input);
        }

        return htmlspecialchars(strip_tags(trim($input)), ENT_QUOTES, 'UTF-8');
    }
}

if (!function_exists('validateEmail')) {
    /**
     * Validate email address
     */
    function validateEmail(string $email): bool
    {
        return filter_var($email, FILTER_VALIDATE_EMAIL) !== false;
    }
}

if (!function_exists('validatePhone')) {
    /**
     * Validate Iranian phone number
     */
    function validatePhone(string $phone): bool
    {
        // Remove spaces and dashes
        $phone = preg_replace('/[\s\-]/', '', $phone);

        // Iranian mobile: 09123456789 or +989123456789
        return preg_match('/^(\+98|0)?9\d{9}$/', $phone) === 1;
    }
}

if (!function_exists('formatPrice')) {
    /**
     * Format price in Toman
     */
    function formatPrice(int $amount): string
    {
        return number_format($amount) . ' تومان';
    }
}

if (!function_exists('generateOrderNumber')) {
    /**
     * Generate order number: KZ-YYYYMMDD-NNNN
     */
    function generateOrderNumber(int $todayCount = 0): string
    {
        $date = date('Ymd');
        $count = str_pad((string)($todayCount + 1), 4, '0', STR_PAD_LEFT);
        return "KZ-{$date}-{$count}";
    }
}

if (!function_exists('logError')) {
    /**
     * Log error message
     */
    function logError(string $message, array $context = []): void
    {
        $logFile = __DIR__ . '/../../storage/logs/error.log';
        $logDir = dirname($logFile);

        if (!is_dir($logDir)) {
            mkdir($logDir, 0755, true);
        }

        $timestamp = date('Y-m-d H:i:s');
        $contextStr = $context ? json_encode($context, JSON_UNESCAPED_UNICODE) : '';
        $logMessage = "[{$timestamp}] {$message} {$contextStr}\n";

        file_put_contents($logFile, $logMessage, FILE_APPEND);
    }
}

if (!function_exists('logInfo')) {
    /**
     * Log info message
     */
    function logInfo(string $message, array $context = []): void
    {
        $logFile = __DIR__ . '/../../storage/logs/app.log';
        $logDir = dirname($logFile);

        if (!is_dir($logDir)) {
            mkdir($logDir, 0755, true);
        }

        $timestamp = date('Y-m-d H:i:s');
        $contextStr = $context ? json_encode($context, JSON_UNESCAPED_UNICODE) : '';
        $logMessage = "[{$timestamp}] INFO: {$message} {$contextStr}\n";

        file_put_contents($logFile, $logMessage, FILE_APPEND);
    }
}

if (!function_exists('uuid')) {
    /**
     * Generate UUID v4
     */
    function uuid(): string
    {
        $data = random_bytes(16);
        $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
        $data[8] = chr(ord($data[8]) & 0x3f | 0x80);

        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }
}
