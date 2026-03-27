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
INSTALL_PATH="${TARS_INSTALL_PATH:-$ROOT/app}"

while [ $# -gt 0 ]; do
    case "$1" in
        --install-path=*)
            INSTALL_PATH="${1#*=}"
            shift
            ;;
        --install-path|-i)
            if [ -z "${2:-}" ]; then
                echo "error: $1 requires a value"
                exit 1
            fi
            INSTALL_PATH="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [--install-path <path>]"
            echo "       $0 [<install_path>]"
            exit 0
            ;;
        *)
            # Backward compatible: first positional arg is install path.
            INSTALL_PATH="$1"
            shift
            ;;
    esac
done

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
    else
        echo "[clone] $target_dir not exists, clone from $branch"
        rm -rf "$target_dir"
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
