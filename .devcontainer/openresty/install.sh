#!/usr/bin/env bash
# install.sh – Dev-container “feature” script for OpenResty + LuaJIT
# Runs as root inside the build container.

set -euo pipefail

# ------------------------------------------------------------------------------
# 1. Prereqs, repo, and OpenResty core
# ------------------------------------------------------------------------------
export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get -y install --no-install-recommends \
    wget gnupg ca-certificates lsb-release

wget -O - https://openresty.org/package/pubkey.gpg \
  | gpg --dearmor -o /usr/share/keyrings/openresty.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openresty.gpg] \
      http://openresty.org/package/ubuntu $(lsb_release -sc) main" \
  > /etc/apt/sources.list.d/openresty.list

apt-get update
apt-get -y install openresty     # includes LuaJIT + LuaRocks

# ------------------------------------------------------------------------------
# 2. Make OpenResty’s LuaJIT & LuaRocks the defaults
# ------------------------------------------------------------------------------
OPENRESTY_HOME=/usr/local/openresty
LUAJIT_BIN="$OPENRESTY_HOME/luajit/bin/luajit"

update-alternatives --install /usr/bin/luajit   luajit      "$LUAJIT_BIN"   50

# ------------------------------------------------------------------------------
# 3. Expose headers / pkg-config and add a profile.d entry
# ------------------------------------------------------------------------------
mkdir -p /usr/local/lib/pkgconfig
ln -sf /usr/local/openresty/luajit/lib/pkgconfig/luajit.pc /usr/local/lib/pkgconfig/luajit.pc

# env for every shell
cat <<'EOF' >/etc/profile.d/openresty.sh
export PATH=/usr/local/openresty/luajit/bin:/usr/local/openresty/bin:$PATH
export LUAJIT_LIB=/usr/local/openresty/luajit/lib
export LUAJIT_INC=/usr/local/openresty/luajit/include/luajit-2.1
export PKG_CONFIG_PATH=/usr/local/openresty/luajit/lib/pkgconfig:${PKG_CONFIG_PATH:-}
EOF
chmod +x /etc/profile.d/openresty.sh

# ------------------------------------------------------------------------------
# 4. Slim the layer
# ------------------------------------------------------------------------------
apt-get clean
rm -rf /var/lib/apt/lists/*
