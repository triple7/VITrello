<?php

// Report all PHP errors
error_reporting(-1);

//Autoload all classes for the APN server features
require_once 'ApnsPHP/Autoload.php';
//Instantiate the server with the proper credentials
$push = new ApnsPHP_Push(
	ApnsPHP_Abstract::ENVIRONMENT_SANDBOX,
	'VlackCerts.pem'
);
$push->setRootCertificationAuthority('GeoTrust_Global_CA.pem');

 $push->setWriteInterval(100);

//get the payload sent by the webhook
if (file_get_contents('php://input') != null){
$body = file_get_contents('php://input');
$payload = json_decode($body, true); 
$action = $payload['action']['id'];
//Create a file that will be retrieved by every device
$file = fopen("payloads/$action.json", "w+");
fwrite($file, json_encode($payload));
fclose($file);
//Connect to the database to get each user
$query = "SELECT * FROM members;";
$connection = new mysqli("localhost", "oseyeris_Vlack", "GeN7NoLo2017", "oseyeris_Vlack");
$push->connect();
if ($connection->connect_error){
error_log("$connection->connect_error \n", 3, "debug.log"); 
}else if ($result = mysqli_query($connection, $query)){
	if(mysqli_num_rows($result) > 0 ){		
while($row = mysqli_fetch_array($result, MYSQLI_ASSOC)){
$token = $row["token"];
	$message = new ApnsPHP_Message($token);
	$message->setBadge(1);
$message->setText("$action");
	$push->add($message);
}
//Send all messages in the queue
$push->send();
//Close the connection
$push->disconnect();
	}
}
}else{
error_log("Error retrieving webhook \n", 3, "debug.log"); 
}
?>