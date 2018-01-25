FROM ubuntu:16.04
ARG COMMIT
ENV COMMIT ${COMMIT:-master}
ENV DEBIAN_FRONTEND noninteractive
RUN add-apt-repository ppa:longsleep/golang-backports && apt-get update && apt-get install -y \
    curl libsnappy-dev autoconf automake libtool pkg-config \
    git golang-go

WORKDIR /
RUN git clone https://github.com/openvenues/libpostal
WORKDIR /libpostal
RUN git checkout $COMMIT
COPY ./build_libpostal.sh .
RUN ./build_libpostal.sh

RUN go get github.com/johnlonganecker/libpostal-rest

RUN go install github.com/johnlonganecker/libpostal-rest

EXPOSE 8080

CMD libpostal-rest
