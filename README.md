# smartphone-cloud-remote-control
***
## About
The purpose is to stream an android phone with kinesis and manage it remotely throught IOT Core

## Getting started
go.sh is helpful to use scrcpy to clone the phone. 
prepare.sh is to make all AWS config. 
You need some roles, I used AmazonKinesisVideoStreamsFullAccess , AWSIoTFullAccess , IAMFullAccess to move forward quickly however more fine grained role should be done (a specific role).

## Todo
- write the advanced subscriber python script for the mqtt to receive instructions
- sync all scripts and parameter
- add aws rekognition to automate

