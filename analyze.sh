#!/bin/bash

# --- 설정 ---
DOCKER_IMAGE="mooooooon/yolo:latest"
RESULT_DIR="../yolo_results"
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

# --rm 옵션을 빼고, --name으로 컨테이너에 이름을 붙여서 실행
docker run --name $CONTAINER_NAME $DOCKER_IMAGE "$1"

# 작업이 끝난 컨테이너로부터 결과 파일만 복사
RESULT_FILE_PATH_IN_CONTAINER="/darknet/predictions.jpg"
LOCAL_RESULT_FILE=$RESULT_DIR/predictions.jpg

echo "분석 완료. 결과 파일을 컨테이너로부터 복사합니다..."
docker cp $CONTAINER_NAME:$RESULT_FILE_PATH_IN_CONTAINER $LOCAL_RESULT_FILE

# 이제 필요 없어진 컨테이너를 삭제해서 깔끔하게 정리
docker rm $CONTAINER_NAME > /dev/null

# 복사된 결과 이미지를 확인하고 열기
if [ -f "$LOCAL_RESULT_FILE" ]; then
  # 리눅스 절대 경로를 Windows가 이해할 수 있는 경로로 변환합니다.
  WIN_PATH=$(wslpath -w "$LOCAL_RESULT_FILE")
  echo "성공! 결과 이미지를 Windows 뷰어로 엽니다: $WIN_PATH"
  # start는 cmd.exe의 내장 명령어이므로, cmd.exe를 통해 실행합니다.
  # ""는 start 명령어 자체의 옵션입니다.
  cmd.exe /c start "" "$WIN_PATH"
else
  echo "오류: 결과 이미지 파일($LOCAL_RESULT_FILE)을 찾을 수 없습니다."
fi