/usr/local/bin/strict.sh

get_composer(){
echo '
version: "3.6"

services:
  plex:
    image: jrromb/rasp-plex:latest
    container_name: plex
    restart: unless-stopped
    ports:
      - "32400:32400/tcp"     
      - "13005:3005/tcp"     
      - "8324:8324/tcp"     
      - "32469:32469/tcp"     
      - "1900:1900/udp"     
      - "32410:32410/udp"     
      - "32412:32412/udp"     
      - "32413:32413/udp"     
      - "32414:32414/udp"    
    environment:
      - "TZ=Europe/London"     
      - "ADVERTISE_IP=http://rasp.local:32400/"     
      - "PLEX_CLAIM=${PLEX_CLAIM}"  
    volumes:
      - "/home/pi/plex/config:/config"
      - "/home/pi/plex/transcode:/transcode"
      - "/media/pi/extern_disk/filmes:/media"    

' 
}


get_composer | docker-compose -f - pull
get_composer | docker-compose -f - up --detach --force-recreate