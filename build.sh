#!/bin/bash

TarsFramework=https://github.com/nbitsy/TarsFramework.git
TarsCpp=https://github.com/nbitsy/TarsCpp.git
TarsProtocol=https://github.com/nbitsy/TarsProtocol.git
TarsWeb=https://github.com/nbitsy/TarsWeb.git
TarsGo=https://github.com/nbitsy/TarsGo.git

TarsFramework_BRANCH=master
TarsCpp_BRANCH=master
TarsProtocol_BRANCH=master
TarsWeb_BRANCH=master
TarsGo_BRANCH=master

ROOT="$(cd "$(dirname "$0")"; pwd)"
INSTALL_PATH="${1:-$ROOT/app}"

# 拉取TarsFramework
git clone -b $TarsFramework_BRANCH $TarsFramework

rm -rf "$INSTALL_PATH" TarsFramework/tarscpp TarsFramework/tarscpp/servant/protocol

cd TarsFramework && git clone -b $TarsCpp_BRANCH $TarsCpp tarscpp && cd -
cd TarsFramework/tarscpp/servant && git clone -b $TarsProtocol_BRANCH $TarsProtocol protocol && cd -

# 编译TarsFramework
cd TarsFramework && ./build.sh cleanall && TARS_INSTALL_PATH="$INSTALL_PATH" ./build.sh all && cd -

cd TarsFramework/build && make install && cd -

# 拉取TarsWeb
git clone -b $TarsWeb_BRANCH $TarsWeb "$INSTALL_PATH/deploy/web" 
# 完后可以到$INSTALL_PATH/deploy/目录执行安装程序或者脚本 

# 拉取TarsGo
# git clone -b $TarsGo_BRANCH $TarsGo TarsGo
