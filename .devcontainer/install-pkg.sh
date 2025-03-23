#!/bin/bash
# featuresでほぼインストールできそうなので現状使ってない
package_list="iputils-ping \
  vim \
  dnsutils \
"
sudo apt update -y
sudo apt install -y --no-install-recommends ${package_list[@]}
# rm -rf /var/lib/lists

# hadolint
# NOTE: .devcontainer/cacheを作成し，compose.yamlのvolume mountで/cacheにマウントしておくことで初回ビルド時のみhadolintのダウンロードが行われることでビルドの高速化を図る
if [ ! -e /cache/hadolint ]; then
  sudo cp /cache/hadolint /usr/local/bin/hadolint
else
  sudo wget -O /usr/local/bin/hadolint https://github.com/hadolint/hadolint/releases/download/v2.12.0/hadolint-Linux-x86_64
  sudo chmod 755 /usr/local/bin/hadolint
  sudo cp /usr/local/bin/hadolint /cache
fi
