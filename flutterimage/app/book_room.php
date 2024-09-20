<?php

include('../connection.php');

// Read JSON input
$input = file_get_contents('php://input');
$data = json_decode($input, true);

// Print the data for debugging
print_r($data);  // Check the output to verify the data received

// Check if data exists
$userId = isset($data['user_id']) ? $data['user_id'] : null;
$rooms = isset($data['rooms']) ? $data['rooms'] : null;
$adults = isset($data['adults']) ? $data['adults'] : null;
$roomType = isset($data['room_type']) ? $data['room_type'] : null;
$totalPrice = isset($data['total_price']) ? $data['total_price'] : null;
$startDate = isset($data['start_date']) ? $data['start_date'] : null;
$endDate = isset($data['end_date']) ? $data['end_date'] : null;

// Validate data
if ($userId === null || $rooms === null || $adults === null || $roomType === null || $totalPrice === null || $startDate === null || $endDate === null) {
    echo json_encode(["status" => "error", "message" => "Missing data"]);
    exit();
}

// Prepare and bind
$stmt = $con->prepare("INSERT INTO bookings (user_id, rooms, adults, room_type, total_price, start_date, end_date) VALUES (?, ?, ?, ?, ?, ?, ?)");
if (!$stmt) {
    echo json_encode(["status" => "error", "message" => "Prepare failed: " . $con->error]);
    exit();
}

$stmt->bind_param("iiissss", $userId, $rooms, $adults, $roomType, $totalPrice, $startDate, $endDate);

if ($stmt->execute()) {
    echo json_encode(["status" => "success", "message" => "Booking confirmed"]);
} else {
    echo json_encode(["status" => "error", "message" => "Execute failed: " . $stmt->error]);
}

$stmt->close();
$con->close();

?>
