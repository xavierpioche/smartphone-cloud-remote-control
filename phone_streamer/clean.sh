aws --profile default iot detach-thing-principal --thing-name ${android_stream} --principal $(jq --raw-output '.certificateArn' certificate.sec)

aws --profile default iot detach-policy --policy-name ${android_policy_iot} --target $(jq --raw-output '.certificateArn' certificate.sec)

CertificateID=$(jq --raw-output '.certificateId' certificate.sec)

aws --profile default iot update-certificate --certificate-id ${CertificateID} --new-status INACTIVE

aws --profile default iot delete-certificate --certificate-id ${CertificateID}

for I in $(aws --profile default iot list-policy-versions --policy-name ${android_policy_iot} --output text | awk '$3 ~ /False/{ print $4 }')
do
	aws --profile default iot delete-policy-version --policy-name ${android_policy_iot} --policy-version-id $I
done

aws --profile default iot delete-policy --policy-name ${android_policy_iot}

aws --profile default iot delete-role-alias --role-alias ${android_role_alias}

#### a revoir : ####
aws iam list-policies --query 'Policies[?PolicyName=='${android_policy}'].Arn' --output text
puis
aws --profile default iam detach-role-policy --role-name ${android_role} --policy-arn ????
###########

aws --profile default iam delete-role --role-name ${android_role}

aws --profile default  iot delete-thing --thing-name ${android_stream}

aws --profile default iot  deprecate-thing-type --thing-type-name ${android_grabbed}

sleep 360
aws --profile default iot delete-thing-type --thing-type-name ${android_grabbed}

rm -f *.json
rm -f *.key
rm -f *.sec
