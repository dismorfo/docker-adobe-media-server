# Usage example
#
# 1) Build container image
# $ docker build -t nyudlts/dlts-ams:latest .
# 2) Run container
# $ docker run -t --name=dlts-ams -p 8000:80 -p 443:443 -p 1111:1111 -p 1935:1935 nyudlts/dlts-ams:latest
FROM centos:7.6.1810

LABEL maintainer="aortiz@nyu.edu"

LABEL version="1.0"

COPY conf/installAMS.input /tmp/ams_latest/installAMS.input
COPY certs /opt/adobe/certs
COPY conf/Adaptor.xml /opt/adobe/ams/conf/_defaultRoot_/Adaptor.xml

RUN set -eux; \
  yum update -y; \
  yum install -y tar python-pip python-wheel python-setuptools; \
  easy_install supervisor; \
  mkdir -p /var/log/supervisor; \
  cd /tmp/ams_latest; \
  curl -O http://download.macromedia.com/pub/adobemediaserver/5_0_8/AdobeMediaServer5_x64.tar.gz ; \
  tar zxvf AdobeMediaServer5_x64.tar.gz -C . --strip-components=1; \
  rm -Rf /tmp/ams_latest/License.txt; \
  sed -i -e 's:read cont < /dev/tty:#read cont < /dev/tty:g' /tmp/ams_latest/installAMS; \
  ./installAMS < /tmp/ams_latest/installAMS.input; \
  rm -Rf /tmp/ams_latest AdobeMediaServer5_x64.tar.gz

COPY conf/supervisord.conf /etc/supervisord.conf

EXPOSE 80 443 1111 1935

CMD [ "/usr/bin/supervisord" ]
