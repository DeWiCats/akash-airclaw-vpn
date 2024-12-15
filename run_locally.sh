#!/usr/bin/env sh


docker run -p 443:443 -p 1194:1194/udp -p 992:992 -p 5555:5555 -p 500:500/udp -p 4500:4500/udp airclaw

# curl -k POST "38.135.51.218:32274" \
#      -H "Content-Type: application/json" \
#      -H "X-VPNADMIN-HUBNAME: " \
#      -H "X-VPNADMIN-PASSWORD: adminakash" \
#      -d '{
#     "jsonrpc": "2.0",
#     "method": "GetServerStatus",
#     "id": 1,
#     "params": {}
# }'