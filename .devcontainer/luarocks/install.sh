#!/usr/bin/env bash

set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
LUAROCKS_VERSION=3.11.1

#TODO: When luarocks is updated to fix the LuaJIT max table issue, change this to use LuaJIT
apt update && apt install -y lua5.4 liblua5.4-dev
cd /tmp
wget https://luarocks.org/releases/luarocks-$LUAROCKS_VERSION.tar.gz
tar xzf luarocks-$LUAROCKS_VERSION.tar.gz
cd luarocks-$LUAROCKS_VERSION
./configure --with-lua="$(dirname $(dirname $(which lua5.4)))"
make -j$(nproc) && make install

# update-alternatives --install /usr/bin/luarocks luarocks $OPENRESTY_HOME/luajit/bin/luarocks 50
apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/luarocks-*
