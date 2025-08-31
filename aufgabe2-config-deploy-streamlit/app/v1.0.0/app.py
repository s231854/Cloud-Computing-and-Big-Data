from flask import Flask, jsonify
import os

app = Flask(__name__)
VERSION = os.environ.get("APP_VERSION", "v1.0.0")

@app.get("/")
def index():
    return f"<h1>Demo-App</h1><p>Version: {VERSION}</p>"

@app.get("/healthz")
def healthz():
    return jsonify(status="ok", version=VERSION)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
