set -x
sudo apt install qemu-user-static -y


IMG_NAME=${IMG_NAME:="jrromb/img-bakery"}
IMG_URL=${IMG_URL:="https://downloads.raspberrypi.org/raspbian_lite_latest"}
RESULT=${RESULT:="$PWD/result"}
TRANSIT=${TRANSIT="$PWD/transit"}
SCRIPT=${SCRIPT:"$PWD/setup-image.sh"}

docker run -i --rm \
-e IMG_URL="${IMG_URL}" \
-v ${TRANSIT}:/transit \
-v ${RESULT}:/result \
-v ${SCRIPT}:/setup-image.sh \
-v /dev:/dev \
--privileged \
${IMG_NAME}


#  result=./result/rasp-custom.img.gz