#!/bin/bash 
. ../env.conf
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/home/xavier/PROJETS/aws-kinesis/amazon-kinesis-video-streams-producer-sdk-cpp/open-source/local/lib
export GST_PLUGIN_PATH=/home/xavier/PROJETS/aws-kinesis/amazon-kinesis-video-streams-producer-sdk-cpp/

ANDROID_SERIAL=`adb get-serialno` 
DATE=`date +%Y%m%d%H%I%S` 
#
SCRCPY="scrcpy"
GSTLAUNCH="gst-launch-1.0"
#
SCRNUM=$(ps -ef | grep ${SCRCPY} | grep ${ANDROID_SERIAL} | wc -l)
if [ ${SCRNUM} -eq 0 ]
then
	nohup ${SCRCPY} --window-title=${PHONE_NAME} --serial=${ANDROID_SERIAL} --always-on-top --window-x=0 --window-y=0 &
	sleep 5
fi
WINDOW_ID=`xwininfo -name ${PHONE_NAME} | grep -e "Window id" | awk '{ print $4 }'` 
echo ${WINDOW_ID}

# Some examples
#VIDEOFILE=${PHONE_NAME}-${DATE}.ogg
#${GSTLAUNCH} ximagesrc xid=${WINDOW_ID} ! video/x-raw,framerate=5/1 ! videoconvert ! theoraenc ! oggmux ! filesink location=${VIDEOFILE}
#
# stream to kinesis - deprecated - use prepare.sh version
#${GSTLAUNCH} ximagesrc xid=${WINDOW_ID} ! videoconvert ! x264enc  bframes=0 key-int-max=45 bitrate=500 tune=zerolatency ! video/x-h264,stream-format=avc,alignment=au ! kvssink stream-name=${AWS_STREAM_NAME} storage-size=128 access-key="${AWS_SECRET_KEY_ID}" secret-key="${AWS_SECRET_ACCESS_KEY}" aws-region="${AWS_DEFAULT_REGION}"
