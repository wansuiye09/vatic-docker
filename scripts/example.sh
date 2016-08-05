#!/bin/bash

# Settings
ID=currentvideo
ANNOTATEDFRAMEPATH=/root/vatic/data/frames_in
TURKOPS="--offline --title HelloTurk!"
LABELS="ak47"
HOST_ADDRESS_FILE=/root/vatic/data/tmp/host_address.txt

# Start database and server
/root/vatic/startup.sh

# Convert videos that need to be converted
/root/vatic/extract.sh

# Set up folders
mkdir -p $ANNOTATEDFRAMEPATH
cd /root/vatic

# start database
#sudo /etc/init.d/mysql start

# load frames and publish. This will print out access URLs.
turkic load $ID $ANNOTATEDFRAMEPATH $LABELS $TURKOPS

# when we publish the videos, we'll also capture the address output and create
# links on a website. We sleep until the host system has time to record its IP address.
HOSTADDRESS=`cat $HOST_ADDRESS_FILE|sed -e "s|\:.*\:|:|" -e "s|\"||g" -e "s| ||g" -e "s|
while [ "$HOSTADDRESS" = "booting..." ]
do
    sleep 1
    HOSTADDRESS=`cat $HOST_ADDRESS_FILE|sed -e "s|\:.*\:|:|" -e "s|\"||g" -e "s| ||g" -e "s|
done
mkdir -p /root/vatic/public/directory

# replace the 'localhost' of the output to the host's address, and format it into
# a series of html links. Save this at the /directory page in the website.
{ turkic publish --offline |\
  tee /dev/fd/3 | sed "s/http/<a href='http/" |\
                  sed "s/offline/offline'> Video Segment <\/a><br>/" |\
                  sed "s/localhost/$HOSTADDRESS/" > /root/vatic/public/directory/index.html; } 3>&1

# add some user interface controls
cat $PWD/ascripts/myhtml.html >> /root/vatic/public/directory/index.html
cp $PWD/ascripts/myphp.php  /root/vatic/public/directory
chgrp -R www-data /root/vatic/data
chmod 775 /root/vatic/data


# open up a bash shell on the server

echo "Please go to http://$HOSTADDRESS/directory for links."

/bin/bash