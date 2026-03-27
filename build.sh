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

clone_or_update() {
    local repo_url="$1"
    local branch="$2"
    local target_dir="$3"

    if [ -d "$target_dir/.git" ]; then
        echo "[update] $target_dir exists, update from $branch"
        (
            cd "$target_dir" || exit 1
            git fetch origin "$branch" && git pull --ff-only origin "$branch"
        )
        return 0
    fi

    if [ -d "$target_dir" ]; then
        echo "[skip] $target_dir exists but is not a git repo, skip clone"
        return 0
    fi

    git clone -b "$branch" "$repo_url" "$target_dir"
}

# 拉取或更新 TarsFramework
clone_or_update "$TarsFramework" "$TarsFramework_BRANCH" "TarsFramework"

clone_or_update "$TarsCpp" "$TarsCpp_BRANCH" "TarsFramework/tarscpp"
clone_or_update "$TarsProtocol" "$TarsProtocol_BRANCH" "TarsFramework/tarscpp/servant/protocol"

# 编译TarsFramework
cd TarsFramework && ./build.sh cleanall && TARS_INSTALL_PATH="$INSTALL_PATH" ./build.sh all && cd -

cd TarsFramework/build && make install && cd -

# 拉取TarsWeb
mkdir -p "$INSTALL_PATH/deploy"
clone_or_update "$TarsWeb" "$TarsWeb_BRANCH" "$INSTALL_PATH/deploy/web"
# 完后可以到$INSTALL_PATH/deploy/目录执行安装程序或者脚本 

# 拉取TarsGo
# git clone -b $TarsGo_BRANCH $TarsGo TarsGo
