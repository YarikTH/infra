FROM ubuntu:12.04
MAINTAINER Matt Godbolt <matt@godbolt.org>

RUN mkdir -p /opt
RUN useradd gcc-user && mkdir /home/gcc-user && chown gcc-user /home/gcc-user

RUN apt-get -y update && apt-get install -y python-software-properties
RUN add-apt-repository -y ppa:chris-lea/node.js && add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get -y update && apt-get install -y \
    curl \
    s3cmd \
    clang \
    g++ \
    g++-4.4 \
    g++-4.5 \
    g++-4.5-arm-linux-gnueabi \
    g++-4.6 \
    g++-4.6-arm-linux-gnueabi \
    g++-4.7 \
    g++-4.7-multilib \
    g++-4.8 \
    g++-4.8-multilib \
    gcc-4.4 \
    gcc-4.5 \
    gcc-4.6 \
    gcc-4.7-base \
    gcc-4.7-multilib \
    gcc-4.8 \
    gcc-4.8-multilib \
    gcc-avr \
    gcc-msp430 \
    gcc-snapshot \
    git \
    libboost-all-dev \
    make \
    nodejs

RUN mkdir -p /opt
RUN mkdir -p /root
COPY .s3cfg /root/
COPY compilers.sh /root/
RUN bash /root/compilers.sh
RUN rm /root/.s3cfg
RUN rm /root/compilers.sh
RUN apt-get purge -y curl s3cmd openjdk-6-jre-lib \
    && apt-get autoremove -y && apt-get clean
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /root/.ssh
COPY known_hosts /root/.ssh/
RUN git clone https://github.com/mattgodbolt/gcc-explorer.git /gcc-explorer
RUN chown -R gcc-user /gcc-explorer
RUN su -c "cd /gcc-explorer && ls && make prereqs" gcc-user

USER gcc-user
WORKDIR /gcc-explorer
VOLUME /gcc-explorer
EXPOSE 10240
CMD ["nodejs", "app.js", "--env", "amazon"]
