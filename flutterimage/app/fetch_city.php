<?php
include('../connection.php');
header('Content-Type: application/json');

$sql = "SELECT * FROM table_city";
$result = $con->query($sql);

$cities = [];
if ($result->num_rows > 0) {
  while($row = $result->fetch_assoc()) {
    $cities[] = $row;
  }
}

$con->close();
echo json_encode($cities);
?>
