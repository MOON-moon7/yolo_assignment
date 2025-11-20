# 1. 우분투 최신 버전을 기반으로 시작 (과제 요구사항)
FROM ubuntu:latest

# 2. 필수 도구 설치 (git, make, wget, gcc 등)
# 과제 수행을 위해 필요한 패키지들을 설치합니다.
RUN apt-get update && apt-get install -y \
    git \
    make \
    wget \
    gcc \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# 3. Darknet(YOLOv3) 소스코드 다운로드 (과제 PDF 2p 참조)
RUN git clone https://github.com/pjreddie/darknet

# 4. 작업 폴더를 'darknet'으로 이동
WORKDIR /darknet

# 5. 소스코드 컴파일 (과제 PDF 2p 참조)
# 이 명령어가 실행되면 'darknet' 실행 파일이 생성됩니다.
RUN make

# 6. 학습된 가중치 파일(yolov3.weights) 다운로드 (과제 PDF 2p 참조)
RUN wget https://data.pjreddie.com/files/yolov3.weights

# 7. 실행 스크립트(run.sh)를 컨테이너 안으로 복사합니다.
COPY run.sh /darknet/

# 8. 스크립트를 실행할 수 있게 권한을 줍니다.
RUN chmod +x /darknet/run.sh

# 9. 컨테이너가 켜지면 이 스크립트를 실행하도록 합니다.
ENTRYPOINT ["/darknet/run.sh"]