#!/bin/bash

#Check if 'hdhomerun_config' is installed
if ! type "hdhomerun_config" > /dev/null 2>&1; then
	echo "HDHomeRun tools is required for this script to work."
	echo "Can be downloaded here: http://www.silicondust.com/support/hdhomerun/downloads/"
	exit
fi

# Check if directory exists, if not then create it
if [ ! -d "~/Videos/Live\ TV" ]; then
	mkdir -p ~/Videos/Live\ TV
fi

# Discover device name
device=$(hdhomerun_config discover |awk '{print $3}')

# Scan channels directly into while loop - pull relevant data and create strm file
hdhomerun_config $device scan 1 | grep -vEi 'tsid|lock|none' | while read output
	do
		if [[ "$output" == "SCANNING"* ]]; then
			scan=$(echo $output | awk '{print $2}')
		fi
		if [[ "$output" == "PROGRAM"* ]]; then
			prog=$(echo $output | awk '{print $2}')
			file=$(echo $output | cut -d':' -f2)
			# Create .strm file
			echo hdhomerun://$device-1/tuner1$file\?channel\=auto\:$scan\&program\=${prog/:/} > ~/Videos/Live\ TV/"${file/\ /}".strm		
		fi
	done
exit 0
