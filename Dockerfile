FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV LIBPOSTAL_VERSION   v1.1-alpha
ENV LIBPOSTAL_DIR       /opt/libpostal
ENV LIBPOSTAL_DATA_DIR  /opt/libpostal_data

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    libsnappy-dev \
    autoconf \
    automake \
    libtool \
    pkg-config \
    git \
    python-software-properties \
    software-properties-common \
  && rm -rf /var/lib/apt/lists/*

RUN add-apt-repository ppa:longsleep/golang-backports && apt-get update && apt-get install -y golang-go && rm -rf /var/lib/apt/lists/*

RUN wget https://github.com/openvenues/libpostal/archive/$LIBPOSTAL_VERSION.tar.gz && mkdir -p $LIBPOSTAL_DIR \
  && tar -xvzf $LIBPOSTAL_VERSION.tar.gz -C $LIBPOSTAL_DIR --strip 1 \
WORKDIR $LIBPOSTAL_DIR

COPY ./build_libpostal.sh .
RUN ./build_libpostal.sh

RUN go get github.com/johnlonganecker/libpostal-rest

RUN go install github.com/johnlonganecker/libpostal-rest

EXPOSE 8080

CMD libpostal-rest