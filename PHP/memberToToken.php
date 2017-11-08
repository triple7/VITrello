<?php

// Report all PHP errors
error_reporting(-1);

if (file_get_contents('php://input') != null){
$body = file_get_contents('php://input');
$payload = json_decode($body, true); 
$user = $payload['user'];
$pass = $payload['password'];
$db = $payload['db'];
$query = $payload['query'];
$connection = new mysqli("localhost", $user, $pass, $db);
if ($connection->connect_error){
echo json_encode($connection->connect_error);
}else if ($result = mysqli_query($connection, $query)){
echo json_encode($result);
}
}else{
echo json_encode("fuck");
}
?>
