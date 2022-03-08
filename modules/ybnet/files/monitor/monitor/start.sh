#!/bin/bash
# Update Time: 2019-10-16
# 入口文件, Shell 模块调用, 传递模块参数
# usage: ./start.sh module-shell-name module-shell-args
# usage: ./start.sh chk-apex-domain
# usage: ./start.sh chk-apex-domain ./src/chk-apex-domain.conf 2 3
# set -x
# set -o nounset
# set -o errexit
set -o pipefail
#
export PATH=/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin
readonly BASE=$(cd "$(dirname "$0")" && pwd)
readonly NAME=$(basename "$0" .sh)
readonly SRC="${BASE}/src"
readonly MODS="${SRC}/mods"
readonly LIBS="${SRC}/libs"
readonly SYS="${SRC}/libs/sys"

# 使用说明
function usage() {
    echo "Usage: ./${NAME}.sh [module-shell-name] [module-shell-args]"
}

# 第一个参数为待调用的 Shell 模块名 e.g. chk-pubg-domain
M_NAME=${1:-"${NAME}"}

# ./src/mods/chk-pubg.domain.sh
MOD="${MODS}/${M_NAME}.sh"
PL_MOD="${MODS}/plugins/${M_NAME}.sh"

[[ -f "${MOD}" ]] && source "${MOD}" "$@" && exit 0
[[ -f "${PL_MOD}" ]] && source "${PL_MOD}" && exit 0
usage
exit 0
