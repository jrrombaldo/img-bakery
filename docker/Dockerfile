FROM ubuntu:bionic

LABEL maintainer="jr.rombaldo@gmail.com"
LABEL repo="https://github.com/jrrombaldo/img-bakery.git"



ENV IMG_URL=https://downloads.raspberrypi.org/raspbian_lite_latest
ENV IMG_NAME=img-bakery
ENV MOUNT=/mnt/custom-img
ENV INCREASE_BY=5G


RUN \
    apt clean  && apt update \
    && apt install qemu qemu-user-static binfmt-support dosfstools parted wget zip udev grep file envsubst -y \
    &&  wget https://raw.githubusercontent.com/Drewsif/PiShrink/master/pishrink.sh --output-document=/usr/local/bin/pishrink.sh

COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*

VOLUME /transit
VOLUME /result

CMD entrypoint.sh

