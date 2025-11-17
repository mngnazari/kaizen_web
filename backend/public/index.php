<?php
/**
 * Kaizen 3D Printing Platform
 * Main API Entry Point
 */

declare(strict_types=1);

// Error reporting for development
error_reporting(E_ALL);
ini_set('display_errors', '1');

// Load Composer autoloader
require __DIR__ . '/../vendor/autoload.php';

// Load environment variables
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/..');
$dotenv->load();

use Slim\Factory\AppFactory;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

// Create Slim app
$app = AppFactory::create();

// Add error middleware
$errorMiddleware = $app->addErrorMiddleware(
    $_ENV['APP_DEBUG'] === 'true',
    true,
    true
);

// Add routing middleware
$app->addRoutingMiddleware();

// Parse JSON body
$app->addBodyParsingMiddleware();

// ==============================================
// CORS Middleware
// ==============================================
$app->add(function (Request $request, $handler) {
    $response = $handler->handle($request);

    $allowedOrigins = explode(',', $_ENV['CORS_ALLOWED_ORIGINS'] ?? '*');
    $origin = $request->getHeaderLine('Origin');

    if (in_array($origin, $allowedOrigins) || in_array('*', $allowedOrigins)) {
        $response = $response
            ->withHeader('Access-Control-Allow-Origin', $origin ?: '*')
            ->withHeader('Access-Control-Allow-Methods', $_ENV['CORS_ALLOWED_METHODS'] ?? 'GET, POST, PUT, DELETE, OPTIONS')
            ->withHeader('Access-Control-Allow-Headers', $_ENV['CORS_ALLOWED_HEADERS'] ?? 'Content-Type, Authorization')
            ->withHeader('Access-Control-Allow-Credentials', $_ENV['CORS_ALLOW_CREDENTIALS'] ?? 'true');
    }

    return $response;
});

// Handle preflight OPTIONS requests
$app->options('/{routes:.+}', function (Request $request, Response $response) {
    return $response;
});

// ==============================================
// Helper Functions
// ==============================================

/**
 * Send JSON response
 */
function jsonResponse(Response $response, array $data, int $status = 200): Response
{
    $response->getBody()->write(json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT));
    return $response
        ->withHeader('Content-Type', 'application/json; charset=utf-8')
        ->withStatus($status);
}

/**
 * Success response
 */
function successResponse(Response $response, $data = null, string $message = '', int $status = 200): Response
{
    $result = ['success' => true];

    if ($message) {
        $result['message'] = $message;
    }

    if ($data !== null) {
        $result['data'] = $data;
    }

    return jsonResponse($response, $result, $status);
}

/**
 * Error response
 */
function errorResponse(Response $response, string $message, $errors = null, int $status = 400): Response
{
    $result = [
        'success' => false,
        'message' => $message
    ];

    if ($errors !== null) {
        $result['errors'] = $errors;
    }

    return jsonResponse($response, $result, $status);
}

// ==============================================
// Routes
// ==============================================

// Health check endpoint
$app->get('/api/health', function (Request $request, Response $response) {
    $data = [
        'status' => 'ok',
        'message' => 'API is running!',
        'version' => '1.0.0',
        'timestamp' => date('c'),
        'environment' => $_ENV['APP_ENV'] ?? 'production'
    ];

    return successResponse($response, $data);
});

// API info endpoint
$app->get('/api', function (Request $request, Response $response) {
    $data = [
        'name' => $_ENV['APP_NAME'] ?? 'Kaizen 3D Printing API',
        'version' => '1.0.0',
        'documentation' => $_ENV['APP_URL'] . '/api/docs',
        'endpoints' => [
            'health' => '/api/health',
            'auth' => [
                'register' => 'POST /api/auth/register',
                'login' => 'POST /api/auth/login',
                'me' => 'GET /api/auth/me'
            ],
            'files' => [
                'upload' => 'POST /api/files/upload',
                'list' => 'GET /api/files',
                'details' => 'GET /api/files/{id}'
            ],
            'orders' => [
                'create' => 'POST /api/orders',
                'list' => 'GET /api/orders',
                'details' => 'GET /api/orders/{id}'
            ]
        ]
    ];

    return successResponse($response, $data);
});

// Test database connection
$app->get('/api/test/db', function (Request $request, Response $response) {
    try {
        $host = $_ENV['DB_HOST'];
        $db = $_ENV['DB_DATABASE'];
        $user = $_ENV['DB_USERNAME'];
        $pass = $_ENV['DB_PASSWORD'];

        $dsn = "mysql:host=$host;dbname=$db;charset=utf8mb4";
        $pdo = new PDO($dsn, $user, $pass, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);

        // Test query
        $stmt = $pdo->query('SELECT COUNT(*) as count FROM users');
        $result = $stmt->fetch();

        $data = [
            'database' => $db,
            'status' => 'connected',
            'users_count' => $result['count']
        ];

        return successResponse($response, $data, 'اتصال به دیتابیس موفق بود');

    } catch (PDOException $e) {
        return errorResponse(
            $response,
            'خطا در اتصال به دیتابیس',
            ['error' => $e->getMessage()],
            500
        );
    }
});

// 404 handler
$app->map(['GET', 'POST', 'PUT', 'DELETE'], '/{routes:.+}', function (Request $request, Response $response) {
    return errorResponse(
        $response,
        'Endpoint مورد نظر یافت نشد',
        ['path' => $request->getUri()->getPath()],
        404
    );
});

// ==============================================
// Run Application
// ==============================================
$app->run();
