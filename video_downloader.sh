#!/bin/bash

# Set the correct download directory
OUTPUT_DIR="$HOME/Documents/GitHub/Charlie-Noon/Video_Downloader/Downloaded_Videos"

# Ensure yt-dlp and ffmpeg are installed
if ! command -v yt-dlp &> /dev/null; then
    echo "yt-dlp not found, installing..."
    brew install yt-dlp
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg not found, installing..."
    brew install ffmpeg
fi

# Check if URL is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <video_url>"
    exit 1
fi

URL="$1"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Download video in highest quality with audio
yt-dlp -f "bv*+ba/best" --merge-output-format mp4 -o "$OUTPUT_DIR/%(title)s.%(ext)s" "$URL"

# Find the downloaded file (assumes it's the most recent MP4 in the folder)
DOWNLOADED_FILE=$(ls -t "$OUTPUT_DIR"/*.mp4 | head -n 1)

# Define the converted filename (appends "_converted")
CONVERTED_FILE="${DOWNLOADED_FILE%.*}_converted.mp4"

# Convert the video to MP4 (H.264 + AAC)
ffmpeg -i "$DOWNLOADED_FILE" -c:v libx264 -crf 23 -preset slow -c:a aac -b:a 192k "$CONVERTED_FILE"

# Remove the original file after conversion (optional)
rm "$DOWNLOADED_FILE"

echo "✅ Conversion complete! Saved as: $CONVERTED_FILE"