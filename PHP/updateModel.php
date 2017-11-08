<?php

// Report all PHP errors
error_reporting(-1);

if (file_get_contents('php://input') != null){
$body = file_get_contents('php://input');
$payload = json_decode($body, true); 
$file = $payload["payload"];
$response = json_decode(file_get_contents("payloads/$file.json"));
$toDelete = fopen("payloads/$file.json", "w+");
unlink("payloads/$file.json");
echo json_encode($response);
}else{
}
?>