<?php

namespace Kaizen\Utils;

use PDO;
use PDOException;

/**
 * Database Connection Manager (Singleton Pattern)
 */
class Database
{
    private static ?Database $instance = null;
    private PDO $connection;

    /**
     * Private constructor to prevent direct instantiation
     */
    private function __construct()
    {
        $host = $_ENV['DB_HOST'] ?? 'localhost';
        $port = $_ENV['DB_PORT'] ?? '3306';
        $database = $_ENV['DB_DATABASE'] ?? 'kaizen_3d';
        $username = $_ENV['DB_USERNAME'] ?? 'root';
        $password = $_ENV['DB_PASSWORD'] ?? '';
        $charset = $_ENV['DB_CHARSET'] ?? 'utf8mb4';

        $dsn = "mysql:host={$host};port={$port};dbname={$database};charset={$charset}";

        try {
            $this->connection = new PDO($dsn, $username, $password, [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES => false,
                PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES {$charset}"
            ]);
        } catch (PDOException $e) {
            error_log("Database connection error: " . $e->getMessage());
            throw new \RuntimeException("خطا در اتصال به دیتابیس: " . $e->getMessage());
        }
    }

    /**
     * Get singleton instance
     */
    public static function getInstance(): self
    {
        if (self::$instance === null) {
            self::$instance = new self();
        }

        return self::$instance;
    }

    /**
     * Get PDO connection
     */
    public function getConnection(): PDO
    {
        return $this->connection;
    }

    /**
     * Execute a SELECT query
     */
    public function select(string $query, array $params = []): array
    {
        try {
            $stmt = $this->connection->prepare($query);
            $stmt->execute($params);
            return $stmt->fetchAll();
        } catch (PDOException $e) {
            error_log("Query error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Execute a SELECT query and return single row
     */
    public function selectOne(string $query, array $params = []): ?array
    {
        try {
            $stmt = $this->connection->prepare($query);
            $stmt->execute($params);
            $result = $stmt->fetch();
            return $result ?: null;
        } catch (PDOException $e) {
            error_log("Query error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Execute INSERT query
     */
    public function insert(string $table, array $data): int
    {
        try {
            $columns = array_keys($data);
            $placeholders = array_map(fn($col) => ":$col", $columns);

            $sql = sprintf(
                "INSERT INTO %s (%s) VALUES (%s)",
                $table,
                implode(', ', $columns),
                implode(', ', $placeholders)
            );

            $stmt = $this->connection->prepare($sql);

            // Bind values with colon prefix
            $params = [];
            foreach ($data as $key => $value) {
                $params[":$key"] = $value;
            }

            $stmt->execute($params);

            return (int) $this->connection->lastInsertId();
        } catch (PDOException $e) {
            error_log("Insert error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Execute UPDATE query
     */
    public function update(string $table, array $data, string $where, array $whereParams = []): int
    {
        try {
            $setParts = [];
            foreach (array_keys($data) as $column) {
                $setParts[] = "$column = :$column";
            }

            $sql = sprintf(
                "UPDATE %s SET %s WHERE %s",
                $table,
                implode(', ', $setParts),
                $where
            );

            $stmt = $this->connection->prepare($sql);

            // Merge data params with where params
            $params = [];
            foreach ($data as $key => $value) {
                $params[":$key"] = $value;
            }
            $params = array_merge($params, $whereParams);

            $stmt->execute($params);

            return $stmt->rowCount();
        } catch (PDOException $e) {
            error_log("Update error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Execute DELETE query
     */
    public function delete(string $table, string $where, array $params = []): int
    {
        try {
            $sql = "DELETE FROM $table WHERE $where";
            $stmt = $this->connection->prepare($sql);
            $stmt->execute($params);

            return $stmt->rowCount();
        } catch (PDOException $e) {
            error_log("Delete error: " . $e->getMessage());
            throw $e;
        }
    }

    /**
     * Begin transaction
     */
    public function beginTransaction(): bool
    {
        return $this->connection->beginTransaction();
    }

    /**
     * Commit transaction
     */
    public function commit(): bool
    {
        return $this->connection->commit();
    }

    /**
     * Rollback transaction
     */
    public function rollBack(): bool
    {
        return $this->connection->rollBack();
    }

    /**
     * Prevent cloning
     */
    private function __clone() {}

    /**
     * Prevent unserialization
     */
    public function __wakeup()
    {
        throw new \Exception("Cannot unserialize singleton");
    }
}
