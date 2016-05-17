FROM debian:jessie
MAINTAINER chrisanthropic <ctarwater@gmail.com>

###########################################################################################
###                            BEGIN CUSTOM Open-Publisher Stuff                        ###
###########################################################################################

RUN echo "deb http://ftp.us.debian.org/debian jessie contrib" > /etc/apt/sources.list.d/contrib.list ;\
    echo "deb http://ftp.us.debian.org/debian jessie-updates contrib" >> /etc/apt/sources.list.d/contrib.list ;
    
## Install TeXlive
# Thanks to https://github.com/papaeye/docker-texlive for the reference
COPY texlive.profile /tmp/
ENV TL_VERSION 2015-20150523

RUN export DEBIAN_FRONTEND=noninteractive \
# Update/Upgrade
    && apt-get clean \
    && apt-get update -y \
    && apt-get upgrade -y \
# Install dependencies
    && apt-get install -y --fix-missing --no-install-recommends perl wget xorriso \
# Download TeXlive source .iso and md5sum
    && wget -q   http://mirrors.ctan.org/systems/texlive/Images/texlive$TL_VERSION.iso \
    && wget -qO- http://mirrors.ctan.org/systems/texlive/Images/texlive$TL_VERSION.iso.sha256 | sha256sum -c \
# Use xorriso to extract .iso
    && osirrox -report_about NOTE -indev texlive$TL_VERSION.iso -extract / /usr/src/texlive \
# Remove .iso
    && rm texlive$TL_VERSION.iso \
# Uninstall xorriso now that we no longer need it
    && apt-get purge -y --auto-remove xorriso \
# Install TeXlive
    && /usr/src/texlive/install-tl -profile /tmp/texlive.profile \
# Remove source
    && rm -rf /usr/src/texlive \
    && rm /tmp/texlive.profile \
# Basic apt cleanup
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*
# Set ENV variable to use texlive path
ENV PATH /texlive/bin/x86_64-linux:$PATH
# Update fonts
RUN luaotfload-tool -u -v
