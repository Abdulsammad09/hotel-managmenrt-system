<?php

include('connection.php');

// Get POST data
$hotel_name = $_POST['hotel_name'];
$rooms = $_POST['rooms'];
$days = $_POST['days'];
$price = $_POST['price'];

// Insert data into database
$sql = "INSERT INTO bookings (hotel_name, rooms, days, price) VALUES ('$hotel_name', '$rooms', '$days', '$price')";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "Booking successful"]);
} else {
    echo json_encode(["success" => false, "message" => "Error: " . $sql . "<br>" . $conn->error]);
}

$conn->close();
?>