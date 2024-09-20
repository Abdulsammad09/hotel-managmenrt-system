<?php

include('connection.php');

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $name = $_POST['name'];
    $city_id = $_POST['city_id'];
    $description = $_POST['description'];
    $address = $_POST['address'];
    $charges = $_POST['charges']; // Per day charges
    $room_type = $_POST['room_type']; // Room type
    $rating = $_POST['rating']; // Rating field

    $imagePaths = [];
    $target_dir = "upload/";

    foreach ($_FILES['images']['tmp_name'] as $key => $tmp_name) {
        $image = $_FILES['images']['name'][$key];
        $target_file = $target_dir . basename($image);

        // Select file type
        $imageFileType = strtolower(pathinfo($target_file, PATHINFO_EXTENSION));

        // Valid file extensions
        $extensions_arr = array("jpg", "jpeg", "png", "gif");

        // Check extension
        if (in_array($imageFileType, $extensions_arr)) {
            // Upload file
            if (move_uploaded_file($_FILES['images']['tmp_name'][$key], $target_file)) {
                $imagePaths[] = $image;
            }
        }
    }

    if (!empty($imagePaths)) {
        $imagePathsString = implode(",", $imagePaths);
        // Include the charges, room type, and rating in the query
        $query = "INSERT INTO table_hotal(`city_id`, `name`, `description`, `image_path`, `address`, `charges_per_day`, `room_type`, `rating`) VALUES('$city_id','$name',  '$description',  '$imagePathsString','$address', '$charges', '$room_type', '$rating')";
        if (mysqli_query($con, $query)) {
            echo "Hotel added successfully";
        } else {
            echo "Error: " . mysqli_error($con);
        }
    } else {
        echo "Failed to upload images";
    }
}
?>
