#!/bin/bash

# --- 설정 ---
# Docker Hub에 올릴 이미지 이름 (Docker Hub ID/이미지 이름:태그)
DOCKER_IMAGE="mooooooon/yolo_assignment:latest"
# 결과물이 저장될 폴더 (프로젝트 폴더 내)
RESULT_DIR="./results"
# --- 설정 끝 ---


if [ -z "$1" ]; then
  echo "오류: 분석할 이미지의 URL을 입력해주세요."
  echo "사용법: ./analyze.sh <이미지_URL>"
  exit 1
fi

mkdir -p $RESULT_DIR

# 컨테이너에 임시로 붙일 이름 (겹치지 않게 $$로 현재 프로세스 ID 사용)
CONTAINER_NAME="yolo_job_$$"

echo "Docker 컨테이너를 실행하여 이미지 분석을 시작합니다..."
echo "사용 이미지: $DOCKER_IMAGE"

# --rm 옵션을 빼고, --name으로 컨테이너에 이름을 붙여서 실행
docker run --name $CONTAINER_NAME $DOCKER_IMAGE "$1"

# 작업이 끝난 컨테이너로부터 결과 파일만 복사
RESULT_FILE_PATH_IN_CONTAINER="/darknet/predictions.jpg"
# 결과 파일 이름에 날짜와 시간을 포함하여 겹치지 않게 함
LOCAL_RESULT_FILE="$RESULT_DIR/result_$(date +%Y%m%d_%H%M%S).jpg"

echo "분석 완료. 결과 파일을 컨테이너로부터 복사합니다..."
docker cp $CONTAINER_NAME:$RESULT_FILE_PATH_IN_CONTAINER $LOCAL_RESULT_FILE

# 이제 필요 없어진 컨테이너를 삭제해서 깔끔하게 정리
docker rm $CONTAINER_NAME > /dev/null

# 복사된 결과 이미지를 확인하고 경로 출력
if [ -f "$LOCAL_RESULT_FILE" ]; then
  echo "--------------------------------------------------"
  echo "성공! 결과가 아래 파일로 저장되었습니다:"
  echo "$LOCAL_RESULT_FILE"
  echo "--------------------------------------------------"
else
  echo "오류: 결과 이미지 파일($LOCAL_RESULT_FILE)을 찾을 수 없습니다."
fi
