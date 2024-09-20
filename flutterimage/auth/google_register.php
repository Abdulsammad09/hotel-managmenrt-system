<?php
require '../connection.php';

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Read raw input and decode JSON
    $inputJSON = file_get_contents('php://input');
    $input = json_decode($inputJSON, true);

    // Check if the input contains the required fields
    $google_id = $input['google_id'] ?? null;
    $email = $input['email'] ?? null;
    $username = $input['username'] ?? null;

    if ($google_id && $email && $username) {
        // Check if user already exists based on email
        $stmt = $con->prepare("SELECT * FROM users WHERE email = ?");
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $result = $stmt->get_result();

        if ($result->num_rows > 0) {
            // User exists
            $user = $result->fetch_assoc();
            
            if ($user['google_id'] === $google_id) {
                // Google ID matches, proceed with existing user
                $response = [
                    'status' => 'User already exists',
                    'user_id' => $user['id'], // Adjust 'id' to match your column name for user_id
                    'email' => $user['email'],
                    'username' => $user['username']
                ];
                echo json_encode($response);
            } else {
                // Email exists but Google ID does not match
                // Update the existing record with the new Google ID
                $stmt = $con->prepare("UPDATE users SET google_id = ? WHERE email = ?");
                $stmt->bind_param("ss", $google_id, $email);

                if ($stmt->execute()) {
                    $user_id = $user['id']; // Use the existing user ID
                    $response = [
                        'status' => 'Google ID updated successfully',
                        'user_id' => $user_id
                    ];
                    echo json_encode($response);
                } else {
                    echo json_encode(["status" => "error", "message" => "Error updating record: " . $stmt->error]);
                }
            }
        } else {
            // Insert new user
            $stmt = $con->prepare("INSERT INTO users (google_id, username, email, role, is_verified) VALUES (?, ?, ?, 'user', 1)");
            $stmt->bind_param("sss", $google_id, $username, $email);

            if ($stmt->execute()) {
                $user_id = $stmt->insert_id; // Get the last inserted ID
                $response = [
                    'status' => 'User registered successfully',
                    'user_id' => $user_id
                ];
                echo json_encode($response);
            } else {
                echo json_encode(["status" => "error", "message" => "Error executing statement: " . $stmt->error]);
            }
        }

        $stmt->close();
    } else {
        echo json_encode(["status" => "error", "message" => "Missing required fields"]);
    }
}

$con->close();
?>
