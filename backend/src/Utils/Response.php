<?php

namespace Kaizen\Utils;

use Psr\Http\Message\ResponseInterface;

/**
 * Response Helper Class
 */
class Response
{
    /**
     * Send JSON response
     */
    public static function json(
        ResponseInterface $response,
        array $data,
        int $status = 200
    ): ResponseInterface {
        $json = json_encode($data, JSON_UNESCAPED_UNICODE | JSON_PRETTY_PRINT);

        $response->getBody()->write($json);

        return $response
            ->withHeader('Content-Type', 'application/json; charset=utf-8')
            ->withStatus($status);
    }

    /**
     * Success response
     */
    public static function success(
        ResponseInterface $response,
        $data = null,
        string $message = '',
        int $status = 200
    ): ResponseInterface {
        $result = ['success' => true];

        if ($message) {
            $result['message'] = $message;
        }

        if ($data !== null) {
            $result['data'] = $data;
        }

        return self::json($response, $result, $status);
    }

    /**
     * Error response
     */
    public static function error(
        ResponseInterface $response,
        string $message,
        $errors = null,
        int $status = 400
    ): ResponseInterface {
        $result = [
            'success' => false,
            'message' => $message
        ];

        if ($errors !== null) {
            $result['errors'] = $errors;
        }

        return self::json($response, $result, $status);
    }

    /**
     * Validation error response
     */
    public static function validationError(
        ResponseInterface $response,
        array $errors,
        string $message = 'خطا در اعتبارسنجی'
    ): ResponseInterface {
        return self::error($response, $message, $errors, 422);
    }

    /**
     * Unauthorized response
     */
    public static function unauthorized(
        ResponseInterface $response,
        string $message = 'احراز هویت ناموفق'
    ): ResponseInterface {
        return self::error($response, $message, null, 401);
    }

    /**
     * Forbidden response
     */
    public static function forbidden(
        ResponseInterface $response,
        string $message = 'دسترسی غیرمجاز'
    ): ResponseInterface {
        return self::error($response, $message, null, 403);
    }

    /**
     * Not found response
     */
    public static function notFound(
        ResponseInterface $response,
        string $message = 'یافت نشد'
    ): ResponseInterface {
        return self::error($response, $message, null, 404);
    }

    /**
     * Server error response
     */
    public static function serverError(
        ResponseInterface $response,
        string $message = 'خطای سرور'
    ): ResponseInterface {
        return self::error($response, $message, null, 500);
    }

    /**
     * Paginated response
     */
    public static function paginated(
        ResponseInterface $response,
        array $items,
        int $total,
        int $page,
        int $perPage
    ): ResponseInterface {
        $data = [
            'items' => $items,
            'pagination' => [
                'current_page' => $page,
                'per_page' => $perPage,
                'total' => $total,
                'total_pages' => (int) ceil($total / $perPage),
                'has_more' => $page * $perPage < $total
            ]
        ];

        return self::success($response, $data);
    }
}
