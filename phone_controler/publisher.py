# import vars from connect.py
from connect import args, client_id, mqtt_connection
# set timestamp
from datetime import datetime
now = datetime.now()
# set temperature
import random
temp = random.randrange(10, 40)
# form the message
message = f'id: {client_id}, temp: {temp}, time: {now}'
# publish the  message
from awscrt import mqtt
import json
mqtt_connection.publish(
    topic=args.topic,
    payload= json.dumps(message),
    qos=mqtt.QoS.AT_LEAST_ONCE
)
print('Message published')