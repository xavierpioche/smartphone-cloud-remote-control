export AWS_STREAM_NAME=${ENV_AWS_STREAM_NAME}
export AWS_ACCESS_KEY_ID=${ENV_AWS_ACCESS_KEY_ID}
export AWS_SECRET_ACCESS_KEY=${ENV_AWS_SECRET_ACCESS_KEY}

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/home/xavier/PROJETS/aws-kinesis/amazon-kinesis-video-streams-producer-sdk-cpp/open-source/local/lib
export GST_PLUGIN_PATH=/home/xavier/PROJETS/aws-kinesis/amazon-kinesis-video-streams-producer-sdk-cpp/

PHONE_NAME="my_phone"
ANDROID_SERIAL=`adb get-serialno` 
DATE=`date +%Y%m%d%H%I%S` 
#
SCRCPY="scrcpy"
GSTLAUNCH="gst-launch-1.0"
VIDEOFILE=${PHONE_NAME}-${DATE}.ogg
#
nohup ${SCRCPY} --window-title=${PHONE_NAME} --serial=${ANDROID_SERIAL} --always-on-top --window-x=0 --window-y=0 &
sleep 5
WINDOW_ID=`xwininfo -name ${PHONE_NAME} | grep -e "Window id" | awk '{ print $4 }'` 
#
#${GSTLAUNCH} ximagesrc xid=${WINDOW_ID} ! video/x-raw,framerate=5/1 ! videoconvert ! theoraenc ! oggmux ! filesink location=${VIDEOFILE}

#$[GSTLAUNCH} ximagesrc xid=${WINDOW_ID} ! rtph264depay ! h264parse ! kvssink stream-name=xpandroidstream storage-size=128

${GSTLAUNCH} ximagesrc xid=${WINDOW_ID} ! videoconvert ! x264enc  bframes=0 key-int-max=45 bitrate=500 tune=zerolatency ! video/x-h264,stream-format=avc,alignment=au ! kvssink stream-name="${AWS_STREAM_NAME}" storage-size=128 access-key="${AWS_SECRET_KEY_ID}" secret-key="${AWS_SECRET_ACCESS_KEY}"
