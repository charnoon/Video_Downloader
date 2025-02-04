from flask import Flask, request, jsonify, send_from_directory
import subprocess
import os

app = Flask(__name__)

# Set the correct directory paths
BASE_DIR = os.path.expanduser("~/Documents/GitHub/Charlie-Noon/Video_Downloader")
OUTPUT_DIR = os.path.join(BASE_DIR, "Downloaded_Videos")

# Ensure the output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

@app.route('/download', methods=['POST'])
def download_video():
    data = request.get_json()
    url = data.get("url")

    if not url:
        return jsonify({"error": "No URL provided"}), 400

    try:
        # Run the video downloader script
        subprocess.run([os.path.join(BASE_DIR, "video_downloader.sh"), url], check=True)

        # Find the latest downloaded file
        files = sorted(os.listdir(OUTPUT_DIR), key=lambda x: os.path.getctime(os.path.join(OUTPUT_DIR, x)), reverse=True)
        if not files:
            return jsonify({"error": "No file found"}), 500
        
        latest_file = files[0]
        file_path = f"/downloaded/{latest_file}"

        return jsonify({"message": "Download complete!", "file": file_path})

    except subprocess.CalledProcessError:
        return jsonify({"error": "Download failed"}), 500

# Serve the downloaded files
@app.route('/downloaded/<filename>')
def serve_file(filename):
    return send_from_directory(OUTPUT_DIR, filename)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)