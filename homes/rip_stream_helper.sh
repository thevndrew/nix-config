#!/usr/bin/env bash
config_yaml=$1
stream=$2

url=$(yq -r ".streams.$stream.url" "$config_yaml")
args=$(yq -r ".streams.$stream.args // \"\"" "$config_yaml")

if [[ -z $(echo "$args" | tr -d '"') ]]; then
   args=""
   if [[ $url == *"youtube"* ]]; then
	args=$(yq -r ".youtube.default_args" "$config_yaml")
   fi
fi

set +o errexit

while true;
do
    # shellcheck disable=SC2086
    eval yt-dlp $args "$url";
    sleep 60;
done
