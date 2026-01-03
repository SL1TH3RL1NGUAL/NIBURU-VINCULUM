import paho.mqtt.client as mqtt
import json
from datetime import datetime

def on_message(client, userdata, msg):
    event = {
        "topic": msg.topic,
        "payload": msg.payload.decode(),
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "echo": True
    }
    print("[witness-log] Event:", json.dumps(event))
    client.publish("capsule/witness/echo", json.dumps(event))

client = mqtt.Client()
client.on_message = on_message
client.connect("localhost", 1883)
client.subscribe("capsule/presence/#")
client.loop_forever()
