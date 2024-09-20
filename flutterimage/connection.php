<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type");

$con = mysqli_connect('localhost','root','','citieguide');

if (!$con) {
    echo "database fail";
}


?>