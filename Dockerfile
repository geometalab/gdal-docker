##
# geodata/gdal
#
# This creates an Ubuntu derived base image that installs the latest GDAL
# subversion checkout compiled with a broad range of drivers.  The build process
# is based on that defined in
# <https://github.com/OSGeo/gdal/blob/trunk/.travis.yml>
#

FROM python:3.6-slim

MAINTAINER Geometalab <geometalab@hsr.ch>

# Install the application.
COPY gdal-checkout.txt /usr/local/src/gdal-docker/
COPY Makefile /usr/local/src/gdal-docker/

RUN apt-get update -y && \
    apt-get install -y make && \
    make -C /usr/local/src/gdal-docker install clean && \
    apt-get purge -y make && \
    rm -rf /var/lib/apt/lists/*

# Externally accessible data is by default put in /data
WORKDIR /data
VOLUME ["/data"]

# Execute the gdal utilities as nobody, not root
USER nobody

# Output version and capabilities by default.
CMD gdalinfo --version && gdalinfo --formats && ogrinfo --formats
