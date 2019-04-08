##
# geometalab/gdal-docker:<GDAL-version>-conda
#
# This creates an Ubuntu derived base image that installs the latest GDAL
# from conda with a broad range of drivers.
#

# Ubuntu 18.04
FROM ubuntu:18.04

MAINTAINER Geometalab <geometalab@hsr.ch>

ENV DEBIAN_FRONTEND=noninteractive

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get update -y && \
    apt-get install -y locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen

ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

ENV TINI_VERSION v0.16.1
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini

# GDAL installation
ARG GDAL_VERSION=2.4.0

RUN conda install --quiet --yes -c conda-forge \
    wheel pip \
    proj4 hdf5 \
    gdal==${GDAL_VERSION}

# Externally accessible data is by default put in /data
WORKDIR /data
VOLUME ["/data"]

# Execute the gdal utilities as nobody, not root
ENTRYPOINT [ "/usr/bin/tini", "--" ]
# Output version and capabilities by default.
CMD gdalinfo --version && gdalinfo --formats && ogrinfo --formats
