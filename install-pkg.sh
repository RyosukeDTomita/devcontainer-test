#!/bin/bash
package_list="net-tools \
  curl \
  wget \
  rsync \
  unzip \
  zip \
  vim \
  jq \
  less \
  git \
"
apt update -y
apt install -y --no-install-recommends ${package_list[@]}
