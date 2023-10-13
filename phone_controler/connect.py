from awsiot import mqtt_connection_builder
from uuid import uuid4
client_id = 'client-' + str(uuid4())
##### parse arguments
import argparse

parser = argparse.ArgumentParser(description="Send and receive messages through and MQTT connection.")

parser.add_argument('--ep', help="IoT device endpoint <some-prefix>.iot.<region>.amazonaws.com", required=True, type=str)
parser.add_argument('--pubcert', help="IoT device public certificate file path", required=True, type=str)
parser.add_argument('--pvtkey', help="IoT device private key file path", required=True, type=str)
parser.add_argument('--cacert', help="IoT device CA cert file path", required=True, type=str)
parser.add_argument('--topic', help="Topic name", required=True, type=str)

args = parser.parse_args()

mqtt_connection = mqtt_connection_builder.mtls_from_path(
    endpoint=args.ep,
    cert_filepath=args.pubcert,
    pri_key_filepath=args.pvtkey,
    ca_filepath=args.cacert,
    client_id=client_id
)

connect_future = mqtt_connection.connect()

# result() waits until a result is available
connect_future.result()
print(f'{client_id} is connected!')

