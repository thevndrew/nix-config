#!/usr/bin/env bash
EXEC_NAME="rip_stream_helper"

# Check if the script is called with an argument
if [ $# -lt 1 ]; then
	echo "Usage: $0 <~/path/to/streams.yml>"
	exit 1
fi

# Stop all stream downloads
if [ $# -lt 2 ]; then
	pgrep -f "$EXEC_NAME" | xargs kill
	pgrep -f yt-dlp | xargs kill
	exit 0
fi

stream=$(yq -r '.streams | keys | .[]' "$1" | fzf)

# shellcheck disable=SC2009
pid_of_downloader=$(ps -ef | grep "$EXEC_NAME" | grep "$stream" | tr -s " " | cut -d" " -f2)
if [ -z "$pid_of_downloader" ]; then
	echo "No PID found for that stream!"
else
	echo "Killing processes with parent PID $pid_of_downloader"
	pkill -9 -P "$pid_of_downloader"
	kill "$pid_of_downloader"
fi
