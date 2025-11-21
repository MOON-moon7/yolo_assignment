#!/bin/bash

# --- 설정 ---
# 이 스크립트가 사용할 Docker 이미지의 전체 이름입니다.
# Docker Hub에 업로드된 공개 주소이므로, 어떤 컴퓨터에서든 이 이미지를 가져올 수 있습니다.
DOCKER_IMAGE="mooooooon/yolo_assignment:latest"
# 분석 결과 이미지가 저장될 폴더의 이름입니다.
# './'는 스크립트가 실행되는 현재 위치를 의미하므로, 결과물이 프로젝트 폴더 내에 생성됩니다.
RESULT_DIR="./results"
# --- 설정 끝 ---

# --- 입력 인자 확인 ---
# 스크립트 실행 시 이미지 URL이 주어졌는지 확인합니다.
# $1은 스크립트에 전달된 첫 번째 인자(이미지 URL)를 의미합니다.
if [ -z "$1" ]; then
  # URL이 없으면 오류 메시지와 사용법을 출력하고 스크립트를 종료합니다.
  echo "오류: 분석할 이미지의 URL을 입력해주세요."
  echo "사용법: ./analyze.sh <이미지_URL>"
  exit 1
fi

# --- 결과물 저장 폴더 생성 ---
# -p 옵션은 폴더가 이미 존재하더라도 오류를 발생시키지 않고, 없으면 새로 생성합니다.
mkdir -p $RESULT_DIR

# --- 임시 컨테이너 이름 설정 ---
# 여러 번 실행해도 컨테이너 이름이 겹치지 않도록, 현재 프로세스 ID($$)를 이름에 포함시킵니다.
CONTAINER_NAME="yolo_job_$$"

echo "Docker 컨테이너를 실행하여 이미지 분석을 시작합니다..."
echo "사용 이미지: $DOCKER_IMAGE"

# --- Docker 컨테이너 실행 ---
# --name: 컨테이너에 고유한 이름을 붙여서 나중에 제어할 수 있게 합니다.
# $DOCKER_IMAGE: 위에서 설정한 Docker 이미지를 사용하여 컨테이너를 생성합니다.
# "$1": 사용자에게 받은 이미지 URL을 컨테이너 내부의 run.sh 스크립트로 전달합니다.
docker run --name $CONTAINER_NAME $DOCKER_IMAGE "$1"

# --- 결과 파일 복사 ---
# 컨테이너 내부의 /darknet/predictions.jpg 파일을
# 호스트(사용자 PC)의 $LOCAL_RESULT_FILE 경로로 복사합니다.
RESULT_FILE_PATH_IN_CONTAINER="/darknet/predictions.jpg"
# 결과 파일 이름이 겹치지 않도록, 현재 날짜와 시간을 파일 이름에 포함시킵니다.
LOCAL_RESULT_FILE="$RESULT_DIR/result_$(date +%Y%m%d_%H%M%S).jpg"

echo "분석 완료. 결과 파일을 컨테이너로부터 복사합니다..."
docker cp $CONTAINER_NAME:$RESULT_FILE_PATH_IN_CONTAINER $LOCAL_RESULT_FILE

# --- 임시 컨테이너 삭제 ---
# 결과 파일만 꺼내온 후, 더 이상 필요 없어진 컨테이너를 삭제하여 시스템을 깨끗하게 유지합니다.
# > /dev/null 은 삭제 시 나오는 메시지를 화면에 출력하지 않도록 합니다.
docker rm $CONTAINER_NAME > /dev/null

# --- 최종 결과 안내 ---
# -f는 파일이 실제로 존재하는지 확인하는 조건입니다.
if [ -f "$LOCAL_RESULT_FILE" ]; then
  echo "--------------------------------------------------"
  echo "성공! 결과가 아래 파일로 저장되었습니다:"
  echo "$LOCAL_RESULT_FILE"
  echo "--------------------------------------------------"
else
  echo "오류: 결과 이미지 파일($LOCAL_RESULT_FILE)을 찾을 수 없습니다."
fi