#!/bin/bash -x
export android_grabbed="samsungs10"
export android_stream=${android_grabbed}-stream
export android_role=${android_grabbed}CertificateBasedIAMRole
export android_role_alias=${android_grabbed}IOTRoleAlias
export android_policy=${android_grabbed}IAMPolicy
export android_policy_iot=${android_grabbed}IOTPolicy
####
cat > iam-policy-document.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "credentials.iot.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
#
cat > iam-permission-document.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kinesisvideo:DescribeStream",
                "kinesisvideo:PutMedia",
                "kinesisvideo:TagStream",
                "kinesisvideo:GetDataEndpoint"
            ],
            "Resource": "arn:aws:kinesisvideo:*:*:stream/${android_stream}/*"
        }
    ]
}
EOF
#
####
#- create the thing type
aws --profile default iot create-thing-type --thing-type-name ${android_grabbed} > iot-thing-type.json
#- create the thing
aws --profile default  iot create-thing --thing-name ${android_stream} --thing-type-name ${android_grabbed} > iot-thing.json
# - create the iam role
aws --profile default iam create-role --role-name ${android_role} --assume-role-policy-document 'file://iam-policy-document.json' > iam-role.json
# - attach a permission to the role
aws --profile default iam put-role-policy --role-name ${android_role} --policy-name ${android_policy} --policy-document 'file://iam-permission-document.json' 
# - create a role alias - needed for iot
aws --profile default iot create-role-alias --role-alias ${android_role_alias} --role-arn $(jq --raw-output '.Role.Arn' iam-role.json) --credential-duration-seconds 3600 > iot-role-alias.json
#aws --profile default iot create-role-alias --role-alias ${android_role_alias} --role-arn $(awk 'NR==1 {print $2 ; exit}' iam-role.json) --credential-duration-seconds 3600 > iot-role-alias.json
##
cat > iot-policy-document.json << EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "iot:AssumeRoleWithCertificate"
            ],
            "Resource": "$(jq --raw-output '.roleAliasArn' iot-role-alias.json)"
        }
    ]
}
EOF
##
# - create the iot policy
aws --profile default iot create-policy --policy-name ${android_policy_iot} --policy-document 'file://iot-policy-document.json'
# - create the certificates
aws --profile default iot create-keys-and-certificate --set-as-active --certificate-pem-outfile certificate.pem --public-key-outfile public.pem.key --private-key-outfile private.pem.key > certificate.sec
# - attach the policy for iot 
aws --profile default iot attach-policy --policy-name ${android_policy_iot} --target $(jq --raw-output '.certificateArn' certificate.sec)
#aws --profile default iot attach-policy --policy-name ${android_policy_iot} --target $(awk 'NR==1 {print $1 ; exit}' certificate.sec)
# - attach the stream
aws --profile default iot attach-thing-principal --thing-name ${android_stream} --principal $(jq --raw-output '.certificateArn' certificate.sec)
#aws --profile default iot attach-thing-principal --thing-name ${android_stream} --principal $(awk 'NR==1 {print $1 ; exit}' certificate.sec)
# get the iot endpoint
aws --profile default iot describe-endpoint --endpoint-type iot:CredentialProvider --output text > iot-credential-provider.sec
# get aws CA certificate
curl --silent 'https://www.amazontrust.com/repository/SFSRootCAG2.pem' --output cacert.pem
# - finally create the stream
aws kinesisvideo create-stream --data-retention-in-hours 24 --stream-name ${android_stream}
# - get the temporary credentials
### can start from there after first launch
#
IOT_GET_CREDENTIAL_ENDPOINT=`cat iot-credential-provider.sec`
curl --silent -H "x-amzn-iot-thingname:${android_stream}" --cert certificate.pem --key private.pem.key https://${IOT_GET_CREDENTIAL_ENDPOINT}/role-aliases/${android_role_alias}/credentials --cacert ./cacert.pem > token.json
AWS_ACCESS_KEY_ID=$(jq --raw-output '.credentials.accessKeyId' token.json) 
AWS_SECRET_ACCESS_KEY=$(jq --raw-output '.credentials.secretAccessKey' token.json) 
AWS_SESSION_TOKEN=$(jq --raw-output '.credentials.sessionToken' token.json) 
aws kinesisvideo describe-stream --stream-name ${android_stream}
#
#
PHONE_NAME="my_phone"
WINDOW_ID=`xwininfo -name ${PHONE_NAME} | grep -e "Window id" | awk '{ print $4 }'`
gst-launch-1.0 ximagesrc xid=${WINDOW_ID} ! videoconvert ! x264enc  bframes=0 key-int-max=45 bitrate=500 tune=zerolatency ! video/x-h264,stream-format=avc,alignment=au ! kvssink stream-name="${android_stream}" aws-region=us-east-1 iot-certificate="iot-certificate,endpoint=cv27mgpj6bkrn.credentials.iot.us-east-1.amazonaws.com,cert-path=certificate.pem,key-path=private.pem.key,ca-path=cacert.pem,role-aliases=${android_role_alias}" access-key="${AWS_SECRET_KEY_ID}" secret-key="${AWS_SECRET_ACCESS_KEY}"
