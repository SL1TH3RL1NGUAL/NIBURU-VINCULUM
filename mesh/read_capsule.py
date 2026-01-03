import json

with open("capsule.json") as f:
    capsule = json.load(f)

print(capsule["initiation"]["task_oath"])

