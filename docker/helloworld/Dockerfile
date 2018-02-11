FROM shyam/alpine-java:8u162b12

MAINTAINER Shyam Sundar <csshyamsundar@gmail.com>

EXPOSE 8080

ENV INSTALL_PATH /app

WORKDIR /

COPY entrypoint.sh .

WORKDIR $INSTALL_PATH

COPY helloworld.war .

ENTRYPOINT ["bash", "/entrypoint.sh"]

# EOF