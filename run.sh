#!/bin/bash

# --- 입력 인자 확인 ---
# 스크립트 실행 시 이미지 URL이 주어졌는지 확인합니다.
# $1은 스크립트에 전달된 첫 번째 인자(이미지 URL)를 의미합니다.
# -z는 문자열이 비어있는지 확인하는 조건입니다.
if [ -z "$1" ]; then
  # URL이 없으면 오류 메시지와 사용법을 출력하고 스크립트를 종료합니다.
  echo "오류: 분석할 이미지의 URL을 입력해주세요."
  echo "사용법: ./run.sh <이미지_URL>"
  exit 1
fi

# --- 이미지 다운로드 ---
# 사용자가 제공한 URL로부터 이미지를 다운로드합니다.
# -O 옵션은 다운로드한 파일의 이름을 'input.jpg'로 강제 지정합니다.
# 이렇게 해야 어떤 URL을 사용하든 항상 동일한 파일 이름으로 분석을 수행할 수 있습니다.
wget "$1" -O input.jpg

# --- Darknet 실행하여 객체 탐지 수행 ---
# 'darknet' 실행 파일을 사용하여 객체 탐지를 수행합니다.
# detector test: 'test' 모드로 detector(탐지기)를 실행합니다.
# cfg/coco.data, cfg/yolov3.cfg, yolov3.weights: 모델 설정 및 가중치 파일들입니다.
# input.jpg: 분석할 대상 이미지 파일입니다.
# -dont_show: 결과를 화면에 창으로 띄우지 않고, 이미지 파일로만 저장하게 합니다.
./darknet detector test cfg/coco.data cfg/yolov3.cfg yolov3.weights input.jpg -dont_show

# 참고: 위 명령어를 실행하면, 탐지 결과가 표시된 이미지가 'predictions.jpg'라는 이름으로 자동 생성됩니다.
