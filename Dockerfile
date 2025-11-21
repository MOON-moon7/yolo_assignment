# --- 베이스 이미지 설정 ---
# 모든 환경의 기초가 될 리눅스 운영체제(Ubuntu 최신 버전)를 선택합니다.
FROM ubuntu:latest

# --- 기본 패키지 및 빌드 도구 설치 ---
# apt-get(Ubuntu의 패키지 관리자)을 업데이트하고,
# YOLOv3(darknet)를 다운로드(git)하고 빌드(make, gcc)하는 데 필요한 최소한의 도구들을 설치합니다.
# -y 옵션은 모든 설치 질문에 'yes'로 자동 응답합니다.
# 마지막에 apt 캐시를 삭제하여 최종 이미지 용량을 줄입니다.
RUN apt-get update && apt-get install -y \
    git \
    make \
    wget \
    gcc \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# --- Darknet 소스 코드 다운로드 ---
# 원작자의 GitHub 저장소에서 darknet 소스 코드를 클론(복제)합니다.
RUN git clone https://github.com/pjreddie/darknet

# --- 작업 디렉토리 설정 ---
# 이후의 모든 명령어들이 실행될 기본 폴더를 /darknet으로 지정합니다.
# cd /darknet 과 같은 효과입니다.
WORKDIR /darknet

# --- Darknet 컴파일 ---
# 소스 코드를 컴파일하여 'darknet'이라는 실행 파일을 생성합니다.
RUN make

# --- 사전 학습된 가중치 파일 다운로드 ---
# 이미지 분석에 사용할, 미리 학습된 모델(가중치) 파일을 다운로드합니다.
# 이 파일은 용량이 크기 때문에 빌드 시 시간이 가장 오래 걸리는 부분 중 하나입니다.
RUN wget https://pjreddie.com/media/files/yolov3.weights

# --- 실행 스크립트 복사 및 권한 설정 ---
# 호스트(사용자 PC)의 run.sh 파일을 컨테이너 내부의 /darknet 폴더로 복사합니다.
COPY run.sh /darknet/
# 복사된 run.sh 파일에 실행 권한을 부여하여, 스크립트가 실행될 수 있도록 만듭니다.
RUN chmod +x /darknet/run.sh

# --- 컨테이너 실행 시 기본 명령어 설정 ---
# docker run 명령어로 컨테이너를 시작할 때, 기본으로 실행될 명령어를 지정합니다.
# 여기서는 컨테이너가 시작되면 바로 /darknet/run.sh 스크립트를 실행하도록 설정합니다.
ENTRYPOINT ["/darknet/run.sh"]
