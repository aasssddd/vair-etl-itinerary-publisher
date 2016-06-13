# Itinerary Job - Publisher

## Description
Itinerary Job is an publisher - subscriber architecture
A Publisher generate PNR list and separate into many pieces, and send them to AWS SQS 
As a worker, consumer listen queue, if there is a message (PNR list), consumer will drain this message, and make a restful web service call to retrieve Itinerary from avantik, then store into DB.

## HOW to USE
### Docker way
    > docker build -t itinerary-publisher .
    > docker run itinerary-publisher

### Console way
    > npm install & npm start

## Configuration
### ftp
PNR list is get from avantik ftp, and pnrSource segment is use to tell publisher which csv file should be grab, and chich column contanins PNR

### AWS
Use your AWS credential and specify the Queue URL

### message_size
Parsed PNR will split int several pieces, and send to SQS. message size indicate how many PNR record in one message. you can do some performance tunning by modify this value.


