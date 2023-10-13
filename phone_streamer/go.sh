. ./env.conf
### can start from there after first launch
#
IOT_GET_CREDENTIAL_ENDPOINT=`cat iot-credential-provider.sec`
curl --silent -H "x-amzn-iot-thingname:${android_stream}" --cert certificate.pem --key private.pem.key https://${IOT_GET_CREDENTIAL_ENDPOINT}/role-aliases/${android_role_alias}/credentials --cacert ./cacert.pem > token.json
AWS_ACCESS_KEY_ID=$(jq --raw-output '.credentials.accessKeyId' token.json) 
AWS_SECRET_ACCESS_KEY=$(jq --raw-output '.credentials.secretAccessKey' token.json) 
AWS_SESSION_TOKEN=$(jq --raw-output '.credentials.sessionToken' token.json) 
aws kinesisvideo describe-stream --stream-name ${android_stream}
#
# same phone_name as grabber directory for the window
WINDOW_ID=`xwininfo -name ${PHONE_NAME} | grep -e "Window id" | awk '{ print $4 }'`
#
gst-launch-1.0 ximagesrc xid=${WINDOW_ID} ! videoconvert ! x264enc  bframes=0 key-int-max=45 bitrate=500 tune=zerolatency ! video/x-h264,stream-format=avc,alignment=au ! kvssink stream-name="${android_stream}" aws-region=${AWS_DEFAULT_REGION} iot-certificate="iot-certificate,endpoint=${IOT_GET_CREDENTIAL_ENDPOINT},cert-path=certs/certificate.pem,key-path=certs/private.pem.key,ca-path=certs/cacert.pem,role-aliases=${android_role_alias}" access-key="${AWS_SECRET_KEY_ID}" secret-key="${AWS_SECRET_ACCESS_KEY}"
 
