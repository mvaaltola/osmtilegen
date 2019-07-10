#!/bin/bash

rm -rf ./tiles
tar -xvf tiles.tar
python3 -m http.server
