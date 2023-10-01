# import vars from connect.py
from connect import args, mqtt_connection
# call back to trigger when a message is received
def on_message_received(topic, payload, dup, qos, retain, **kwargs):
    print("Received message from topic '{}': {}".format(topic, payload))

##### subscribe to topic
from awscrt import mqtt
subscribe_future, packet_id = mqtt_connection.subscribe(
    topic=args.topic,
    qos=mqtt.QoS.AT_LEAST_ONCE,
    callback=on_message_received
)

# result() waits until a result is available
subscribe_result = subscribe_future.result()
print(f'Subscribed to {args.topic}')

import threading
threading.Event().wait()