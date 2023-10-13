#!/bin/bash 
. ../env.conf
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
aws --profile default iot create-thing-type --thing-type-name ${android_type} > iot-thing-type.json

#- create the thing
aws --profile default  iot create-thing --thing-name ${android_grabbed} --thing-type-name ${android_grabbed} > iot-thing.json

# - create the iam role
aws --profile default iam create-role --role-name ${android_role} --assume-role-policy-document 'file://iam-policy-document.json' > iam-role.json

# - attach a permission to the role
aws --profile default iam put-role-policy --role-name ${android_role} --policy-name ${android_policy} --policy-document 'file://iam-permission-document.json' 

# - create a role alias - needed for iot
aws --profile default iot create-role-alias --role-alias ${android_role_alias} --role-arn $(jq --raw-output '.Role.Arn' iam-role.json) --credential-duration-seconds 43200 > iot-role-alias.json
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

# - attach the thing to the certificate
aws --profile default iot attach-thing-principal --thing-name ${android_stream} --principal $(jq --raw-output '.certificateArn' certificate.sec)

# get the iot endpoint
aws --profile default iot describe-endpoint --endpoint-type iot:CredentialProvider --output text > iot-credential-provider.sec

# get aws CA certificate
curl --silent 'https://www.amazontrust.com/repository/SFSRootCAG2.pem' --output cacert.pem

# - finally create the stream
aws kinesisvideo create-stream --data-retention-in-hours 24 --stream-name ${android_stream}
