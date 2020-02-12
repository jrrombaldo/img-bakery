IMG_NAME="jrromb/img-bakery" 

IMG_URL=${IMG_URL:="https://downloads.raspberrypi.org/raspbian_lite_latest"}

RESULT="$PWD/result"
TRANSIT="$PWD/transit"
SCRIPT="$PWD/setup-image.sh"

docker run -id --rm \
 -e IMG_URL="${IMG_URL}" \
 -v ${TRANSIT}:/transit \
 -v ${RESULT}:/result \
 -v ${SCRIPT}:/setup-image.sh \
 -v /dev:/dev \
 --privileged \
 jrromb/img-bakery
