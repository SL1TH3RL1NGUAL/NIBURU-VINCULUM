import json
import subprocess

def get_txt(domain):
    result = subprocess.run(["dig", "TXT", domain, "+short"], capture_output=True, text=True)
    return result.stdout.strip().replace('"', '')

def update_capsule_db(domain, db_path):
    txt = get_txt(domain)
    if "capsule-origin=" in txt:
        parts = dict(item.split("=") for item in txt.split(";") if "=" in item)
        with open(db_path, "r+") as f:
            db = json.load(f)
            db = [c for c in db if c["domain"] != domain]
            db.append({
                "domain": domain,
                "cid": parts.get("capsule-origin"),
                "peerid": parts.get("peerid"),
                "status": parts.get("status", "unknown"),
                "mesh_layer": parts.get("mesh", "unknown"),
                "timestamp": parts.get("timestamp", "unknown"),
                "mac": None,
                "ip": None
            })
            f.seek(0)
            json.dump(db, f, indent=2)
            f.truncate()

update_capsule_db("capsule.blackcorp.me", "/data/data/com.termux/files/home/chamber/db/capsules.json")
update_capsule_db("a36.vinculum.blackcorp.me", "/data/data/com.termux/files/home/chamber/db/capsules.json"
