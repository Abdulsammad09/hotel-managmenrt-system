<?php
include('../connection.php');

if (isset($_GET['user_id']) || isset($_GET['google_id'])) {
    $user_id = $_GET['user_id'] ?? null;
    $google_id = $_GET['google_id'] ?? null;

    // Prepare SQL based on whether user_id or google_id is provided
    if ($user_id) {
        if (!is_numeric($user_id)) {
            echo json_encode(["status" => "Error", "message" => "Invalid user ID format"]);
            exit();
        }
        $stmt = $con->prepare("SELECT username, email FROM users WHERE id = ?");
        $stmt->bind_param("i", $user_id);
    } elseif ($google_id) {
        $stmt = $con->prepare("SELECT username, email FROM users WHERE google_id = ?");
        $stmt->bind_param("s", $google_id);
    }

    // Check if the statement preparation is successful
    if ($stmt === false) {
        echo json_encode(["status" => "Error", "message" => "Failed to prepare the statement: " . $con->error]);
        exit();
    }

    // Execute the query
    $stmt->execute();
    $stmt->store_result();
    $stmt->bind_result($name, $email);

    // Check if a result is found
    if ($stmt->num_rows > 0) {
        $stmt->fetch();
        echo json_encode([
            "status" => "Success",
            "name" => $name,
            "email" => $email,
        ]);
    } else {
        echo json_encode(["status" => "Error", "message" => "User not found"]);
    }

    // Close the statement
    $stmt->close();
} else {
    echo json_encode(["status" => "Error", "message" => "User ID or Google ID not provided"]);
}

// Close the connection
$con->close();
?>
