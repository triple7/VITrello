# VITrello
Complete swift wrapper for the Trello API

#Introduction
First, some acknowledgement to Joel Fischer who started the initiative with HelloTrello which is my starting point for this wrapper [repo here](https://github.com/livio/HelloTrello "HelloTrello swift library"). We have agreed to push this version to a different repo as there are enough changes to make it a completely different library. Just to be clear on this front :) 

HelloTrello consists of a set of enums and functions to get certain objects from the trello API using the Alamofire pod which is an elegant HTTP request library for swift. It is however limited to a few objects and only for retrieving data. 

I have extended the capabilities of HelloTrello to include every object in the trello API, these are:
1. Boards
2. Lists
3. Cards
4. Checklists
5. CheckItems
6. Labels
7. Comments
8. Attachments
9. members
10. Webhooks
11. Organizations (teams)
12. Actions
13. BoardPrefs
14. Batch

As recommended by the Trello dev team, I have also included a set of php scripts to manage Apple remote push notification services via a global entrust certificate which does the following:
1. Request a deviceToken to the APN server and send it to the provider server for preparing incoming payloads
2. Set the webhooks to use on a predefined object
3. Receive the webhook server side and break apart the payload into an SQL entry and a file
4. Send the payload in the correct format to the APN server as a small message (under 2kBytes)
5. When the notification arrives on the device, send a short request for the payload to the server 
6. Dispatch the payload and delete the local copy when all users in a board using the service have gotten it.

So far, this is a 6 point traversal through the network, which I find a bit harsh but the response time is fairly reasonable (between 1.5-2.6 seconds from local modify to it mirroring on the data model). It seems that new updates coming from other members is slightly faster (under a second).

The push to the APN server is performed by APNSPHP [Repo here](https://github.com/immobiliare/ApnsPHP "PHP scripts for the APN service")


#Setup

#h2 trello API key and Tokens

You need to create both a developer's API key and authorisation token for single devices. the process is explained [here](https://trello.com/app-key)

Once you got these, change the keys in APIManager.swift to reflect your own access authorisations.

#h2 Server-side components

These include:
1. db.txt: import this file into your SQL database
2. memberToToken.php: This retrieves token information coming from your device
3. webhook.php: Change the credentials for the sqli_connect(args)
4. update.php: This receives the identifier of the payload to send back to the requesting device.

For the above, you need to change Trello.swift and provide your own server's URL

 let callbackURL = "http://your_own_URL/webhook.php"
	private let tokenURL = "http://your_own_URL/memberToToken.php"
		let updateURL = "http://your_own_domain/updateModel.php"
	fileprivate var dbParams = ["user": "your_DB_username" as String, "password": "your_user_pass" as String, "db": "your_DB_name" as String]
	

Also, change user, pass and db in webhook.php with the same credentials.

#h2 APNS service

This is the lengthier part, but I have broken it down to each process with the best step by step guides I found on the net:
1. register your app bundle for push notification [Apple developer website](https://developer.apple.com/library/content/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html#//apple_ref/doc/uid/TP40008194-CH8-SW1)
2. Request an APN certificate to download on your mac [Tutorial](https://quickblox.com/developers/How_to_create_APNS_certificates)
3. Save and transform the certificate authority and private keys into one .pem file (command line below)
4. put those files in the same directory as all the .php scripts and change the file names in the APNSPHP class push.php

#h3 .p12 to .pem conversion

Here is the command to type in terminal once you have saved both authority and private key to one single .p12 file:

openssl pkcs12 -in your_certificate.p12 -out your_certificate.pem -nodes -clcerts

Reflect this in webhook.php by finding the below lines:

$push = new ApnsPHP_Push(
	ApnsPHP_Abstract::ENVIRONMENT_SANDBOX,
	'your_certificate.pem'
);
$push->setRootCertificationAuthority('GeoTrust_Global_CA.pem');


#h1 The swift data model:

As the trello documentation says, the hierarchy for trello objects are as in the following vector:

organization > board > cardlist > card > checklist > checkItem

To keep to this model, I've coded the classes so that each object automatically requests any existing child objects upon first loading organizations (teams).

#h1 AppDelegate

Depending on the platform you will be using, the functions differ in form but not function. For the purpose of this guide, I have added a mac OS appDelegate.swift. You will need to implement your own callback function whenever a new notification arrives from the APN server.

#The info.plist file

The provided info.plist allows requests to be passed through unsecure http for the purpose of testing, but Apple will request a secure https connection for production. To this effect, you need to specify your domain in the .plist file as per vbelow:

	<key>NSExceptionDomains</key>
	<dict>
		<key>your_domain</key>
		<dict>
			<key>NSExceptionAllowsInsecureHTTPLoads</key>
			<true/>
			<key>NSIncludesSubdomains</key>
			<true/>
		</dict>
	</dict>
 
#Further enhancements

Although I have tried to make this as comprehensive as possible in 3 weeks between work, life and other stuff, there are still some details missing which I invite anyone to complete for the benefit of all. These are:

1. attachments uploading
2. cleanup of the enums and updating APIFunctions.swift to unlock all the remaining features which keys are set to -1, meaning they call a void function and do nothing
3. Change the classes to structs or something better suited
4. Further abstract the get/post/delete functionalities 
5. Change a few things in the php scripts to allow a large number of users to use the service
6. add more security to server sides
7. Add some powerups and tags objects (the latter is still experimental as of today)

#License

This is open source and I encourage anyone with more coding hours to make this better, more efficient, less memory intensive, etc etc so that we can easily plug the trello API into various innovative scenarios by piggy backing on a robust organisational service.