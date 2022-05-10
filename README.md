

# IMG Bakery
[![Build Status](https://travis-ci.org/jrrombaldo/img-bakery.svg?branch=master)](https://travis-ci.org/jrrombaldo/img-bakery)
![images pipeline](https://github.com/jrrombaldo/img-bakery/workflows/images%20pipeline/badge.svg)

The `IMG Bakery` takes an operating system image URL, downloads and produces a new image with the given customisations. It has been tested with different versions/flavours of Raspbian and Ubunutu; however, it should work with UNIX based OS.

More specifically, the `IMG Bakery` takes an operating system URL and a set of customisation scripts. It then downloads the image, expands its partition, injects the scripts, emulates, executes the scripts, and compacts resulted image.

This project installs [Docker](https://github.com/docker/docker-install) and [oh my zsh](https://github.com/ohmyzsh/ohmyzsh) as examples; feel free to remove them.

## How to run
`IMG Bakery` runs inside the Docker container, so it does not require any customisation on your computer other than Docker running. [Further details on how to install Docker](https://github.com/docker/docker-install)

It takes three required parameters/volume
 - `/result`: volume where the images (original and produced) are saved
 - `/setup-image.sh`: the shell script file with the customisations. 
 - `IMG_URL` environment variable point to the operating system image. If none is specified, it uses the [latest Raspbian lite](https://downloads.raspberrypi.org/raspbian_lite_latest)

 Optional parameters are:
 - `INCREASE_BY`: environment variable with the size of the image needed to be expanded to support the customisations. The default value is `5G`
 - `IMG_NAME`: environment variable with the produced image file name. Default is `img-bakery-result.img`
 - `/transit`: volume that contains all files to be injected into the image. It should follow the directory structure files to be injected, for example, the file `./transit/etc/ssh/ssh_conf` is injected on `/etc/ssh/ssh_config`

 * The following example takes the Raspbian lite and installs Docker and 'oh my zsh'.

 ```
git clone https://github.com/jrrombaldo/img-bakery.git
cd img-bakery

IMG_URL=https://downloads.raspberrypi.org/raspbian_lite_latest
RESULT="$PWD/result"
TRANSIT="$PWD/transit"
SCRIPT="$PWD/setup-image.sh"

docker run -it --rm \
 -e IMG_URL="${IMG_URL}" \
 -v ${TRANSIT}:/transit \
 -v ${RESULT}:/result \
 -v ${SCRIPT}:/setup-image.sh \
 -v /dev:/dev \
 --privileged \
 jrromb/img-bakery

 ```

Attention to the `--privileged`, is required to be able to emulate the image.

## Appreciation
This is provided as free for everyone basis; however, the maintainer still has to pay for beers and tattoos. Any support is much appreciated.

[![](https://www.paypalobjects.com/en_GB/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=e-junior%40live.com&currency_code=GBP&source=url)
