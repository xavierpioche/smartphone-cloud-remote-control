export IOT_PORT=8883
export IOT_DEV=$(aws iot describe-endpoint --region us-east-1 --output text --query endpointAddress --endpoint-type iot:Data-ATS)
#
export PUBCERT="pub-cert.pem"
export PVTKEY="pvt-key.pem"
export CACERT="ca-cert.pem"
export PUBKEY="pub-key.pem"
#
export TOPIC="ordermanager"
#
# test connection
#python3 connect.py --ep ${IOT_DEV} --pubcert ${PUBCERT} --pvtkey ${PVTKEY} --cacert ${CACERT} --topic ${TOPIC}
# send a message
#python3 publisher.py --ep ${IOT_DEV} --pubcert ${PUBCERT} --pvtkey ${PVTKEY} --cacert ${CACERT} --topic ${TOPIC}
# wait and handle received message
python3 subscriber.py --ep ${IOT_DEV} --pubcert ${PUBCERT} --pvtkey ${PVTKEY} --cacert ${CACERT} --topic ${TOPIC}
