#!/bin/bash

# 1. 사용자가 입력한 URL($1)을 받아서 'input.jpg'라는 이름으로 다운로드합니다.
wget -O input.jpg "$1"

# 2. 다운로드된 'input.jpg'를 가지고 Darknet을 실행합니다.
./darknet detector test cfg/coco.data cfg/yolov3.cfg yolov3.weights input.jpg