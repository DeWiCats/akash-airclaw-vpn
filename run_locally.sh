#!/usr/bin/env sh

docker run -p 443:443 -p 1194:1194/udp -p 992:992 -p 5555:5555 -p 500:500/udp -p 4500:4500/udp --rm -ti andrey01/softether:4.38-9760
