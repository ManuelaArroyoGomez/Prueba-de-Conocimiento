<?php
$dotenv = parse_ini_file(__DIR__ . '/.env', false, INI_SCANNER_RAW);

$host = $dotenv['DB_HOST'] ?? '127.0.0.1';
$port = $dotenv['DB_PORT'] ?? '3306';
$db   = $dotenv['DB_NAME'] ?? 'testdb';
$user = $dotenv['DB_USER'] ?? 'testuser';
$pass = $dotenv['DB_PASS'] ?? 'testpass';

try {
  $pdo = new PDO("mysql:host=$host;port=$port;dbname=$db;charset=utf8mb4", $user, $pass, [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
  ]);
} catch (PDOException $e) {
  http_response_code(500);
  echo json_encode(['error' => 'Error de conexión a la base de datos', 'detail' => $e->getMessage()]);
  exit;
}