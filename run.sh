#!/bin/bash

set -xe

echo "Requesting spot instance..."

HOSTNAME=$(python3 request.py)

# check ssh port 22
while ! nc -z $HOSTNAME 22; do
  sleep 0.5 # wait for half a second before check again
done

scp -oStrictHostKeyChecking=no -i ~/.ssh/osmtilegen.pem gen-tiles.py 'ubuntu@'$HOSTNAME:/tmp/gen-tiles.py

scp -oStrictHostKeyChecking=no -i ~/.ssh/osmtilegen.pem mapgen.sh 'ubuntu@'$HOSTNAME:/home/ubuntu

echo "Generating maps..."

ssh -oStrictHostKeyChecking=no -i ~/.ssh/osmtilegen.pem -oServerAliveInterval=100 'ubuntu@'$HOSTNAME "nohup bash /home/ubuntu/mapgen.sh > mapgen.out 2> mapgen.err < /dev/null &"

echo "Waiting for map generation to complete..."

while ! ssh -oStrictHostKeyChecking=no -i ~/.ssh/osmtilegen.pem 'ubuntu@'$HOSTNAME test -f /tmp/tiles.tar; do
    sleep 30
done

sleep 30

echo "Copying data to local disk..."

scp -oStrictHostKeyChecking=no -i ~/.ssh/osmtilegen.pem 'ubuntu@'$HOSTNAME:/tmp/tiles.tar .

echo "Done. Shutting down remote host..."

ssh -oStrictHostKeyChecking=no -i ~/.ssh/osmtilegen.pem 'ubuntu@'$HOSTNAME sudo shutdown -h now

echo "Map generation finished."
