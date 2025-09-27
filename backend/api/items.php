<?php
header('Content-Type: application/json');
require_once __DIR__ . '/../cors.php';
require_once __DIR__ . '/../db.php';

$method = $_SERVER['REQUEST_METHOD'];
$id = $_GET['id'] ?? null;

$payload = file_get_contents('php://input');
$data = json_decode($payload, true) ?? [];

function validate($data) {
  $errors = [];
  if (!isset($data['nombre']) || trim($data['nombre']) === '') {
    $errors['nombre'] = 'El nombre es obligatorio';
  } else if (mb_strlen($data['nombre']) > 100) {
    $errors['nombre'] = 'Máximo 100 caracteres';
  }
  if (isset($data['descripcion']) && mb_strlen($data['descripcion']) > 1000) {
    $errors['descripcion'] = 'Máximo 1000 caracteres';
  }
  return $errors;
}

try {
  switch ($method) {
    case 'GET':
      $stmt = $pdo->query("SELECT id, nombre, descripcion, completado FROM items ORDER BY id DESC");
      echo json_encode($stmt->fetchAll());
      break;

    case 'POST':
      $errors = validate($data);
      $comp = isset($data['completado']) ? (int)!!$data['completado'] : 0;
      if ($errors) { http_response_code(422); echo json_encode(['errors'=>$errors]); break; }
      $stmt = $pdo->prepare("INSERT INTO items (nombre, descripcion, completado) VALUES (:n, :d, :c)");
      $stmt->execute([':n'=>$data['nombre'], ':d'=>$data['descripcion'] ?? null, ':c'=>$comp]);
      $id = $pdo->lastInsertId();
      echo json_encode(['id'=>$id, 'nombre'=>$data['nombre'], 'descripcion'=>$data['descripcion'] ?? null, 'completado'=>$comp]);
      break;

    case 'PUT':
      if (!$id) { http_response_code(400); echo json_encode(['error'=>'Falta id']); break; }
      $errors = validate($data);
      $comp = isset($data['completado']) ? (int)!!$data['completado'] : 0;
      if ($errors) { http_response_code(422); echo json_encode(['errors'=>$errors]); break; }
      $comp = isset($data['completado']) ? (int)!!$data['completado'] : 0;
      $stmt = $pdo->prepare("UPDATE items SET nombre=:n, descripcion=:d, completado=:c WHERE id=:id");
      $stmt->execute([':n'=>$data['nombre'], ':d'=>$data['descripcion'] ?? null, ':c'=>$comp, ':id'=>$id]);
      echo json_encode(['id'=>$id, 'nombre'=>$data['nombre'], 'descripcion'=>$data['descripcion'] ?? null, 'completado'=>$comp]);
      break;

    case 'DELETE':
      if (!$id) { http_response_code(400); echo json_encode(['error'=>'Falta id']); break; }
      $stmt = $pdo->prepare("DELETE FROM items WHERE id = :id");
      $stmt->execute([':id'=>$id]);
      echo json_encode(['deleted'=>true]);
      break;
    
    case 'PATCH':
      if (!$id) { http_response_code(400); echo json_encode(['error'=>'Falta id']); break; }
      $comp = isset($data['completado']) ? (int)!!$data['completado'] : 0;
      $stmt = $pdo->prepare("UPDATE items SET completado=:c WHERE id=:id");
      $stmt->execute([':c'=>$comp, ':id'=>$id]);
      echo json_encode(['id'=>$id, 'completado'=>$comp]);
      break;
      
    default:
      http_response_code(405);
      echo json_encode(['error'=>'Método no permitido']);
  }
} catch (Throwable $e) {
  http_response_code(500);
  echo json_encode(['error'=>'Error en el servidor', 'detail'=>$e->getMessage()]);
}