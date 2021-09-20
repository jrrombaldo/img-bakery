set -x
# sudo apt install qemu-user-static -y

# exit when any command fails
set -e

IMG_NAME=${IMG_NAME:="jrromb/img-bakery"}
IMG_URL=${IMG_URL:="https://cdimage.ubuntu.com/releases/20.04.2/release/ubuntu-20.04.2-preinstalled-server-arm64+raspi.img.xz"}
# IMG_URL=${IMG_URL:="http://cdimage.ubuntu.com/releases/18.04.4/release/ubuntu-18.04.4-preinstalled-server-arm64+raspi3.img.xz"}
# IMG_URL=${IMG_URL:="http://cdimage.ubuntu.com/releases/19.10.1/release/ubuntu-19.10.1-preinstalled-server-arm64+raspi3.img.xz"}
RESULT=${RESULT:="$PWD/result"}
TRANSIT=${TRANSIT="$PWD/transit"}
SCRIPT=${SCRIPT:="$PWD/setup-image.sh"}

# to run only on dev
# docker build -t ${IMG_NAME} ./docker
# to run only on build
docker pull ${IMG_NAME}

docker run -d --rm \
-e IMG_URL="${IMG_URL}" \
-v ${TRANSIT}:/transit \
-v ${RESULT}:/result \
-v ${SCRIPT}:/setup-image.sh \
-v /dev:/dev \
--privileged \
--rm \
${IMG_NAME}
