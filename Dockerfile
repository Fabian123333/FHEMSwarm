FROM debian:10
RUN apt update
RUN apt upgrade -y
RUN apt install --no-install-recommends -y curl rsync perl usbutils procps default-mysql-client libdbi-perl libdbd-mysql-perl

RUN cpan install Net::MQTT::Simple
RUN cpan install Net::MQTT::Constants

RUN mkdir -p /opt/fhem
RUN curl http://fhem.de/fhem-6.0.tar.gz -o /fhem.tar.gz

ADD ./entrypoint.sh /entrypoint.sh

ENTRYPOINT /entrypoint.sh
EXPOSE 8083 8083
EXPOSE 1883 1883
