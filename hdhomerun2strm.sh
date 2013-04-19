#!/bin/bash

#Check if 'hdhomerun_config' is installed
if ! type "hdhomerun_config" > /dev/null 2>&1; then
	echo "HDHomeRun tools is required for this script to work."
	echo "Can be downloaded here: http://www.silicondust.com/support/hdhomerun/downloads/"
	exit
fi

if [ -z "$1" ]; then 
	echo "usage: $0 <tuner_number> <destination directory>"
	exit
fi

directory=$2
tuner=$1

# Discover device name
device=$(hdhomerun_config discover |awk '{print $3}')
if [[ "$device" == "found"* ]]; then
	echo "No HDHomeRun device found." 
	exit 0
else
	echo "Found HDHomeRun device '$device'."
fi

# Scan channels directly into while loop - pull relevant data and create strm file
echo "Started scanning on tuner ${tuner}."
hdhomerun_config $device scan $tuner | grep -vEi 'tsid|lock|none' | while read output
	do
		if [[ "$output" == "SCANNING"* ]]; then
			channel=$(echo $output | awk '{print $3}' | grep -o '[0-9]\+')
			echo "Scanning channel: $channel"
		fi
		if [[ "$output" == "PROGRAM"* ]]; then
			program=$(echo $output | awk '{print $2}' | grep -o '[0-9]\+')
			channelname=$(echo $output | sed -E "s/.+: [0-9]+ (.+)/\1/g")
			# Create .strm file
			echo "Created strm file for $channelname"
			echo "hdhomerun://${device}-${tuner}/tuner${tuner}?channel=auto:${channel}&program=${program}" >"${directory}/${channelname}.strm"
		fi
	done
	echo "Finished."
exit 0
