#!/usr/bin/env bash

if [[ -t 1 ]] && [[ "${NO_COLOR:-}" != "1" ]]; then
  C_INFO=$'\033[1;34m'
  C_OK=$'\033[1;32m'
  C_WARN=$'\033[1;33m'
  C_ERROR=$'\033[1;31m'
  C_RESET=$'\033[0m'
else
  C_INFO=""
  C_OK=""
  C_WARN=""
  C_ERROR=""
  C_RESET=""
fi

log_info()  { echo "${C_INFO}[INFO]${C_RESET} $*"; }
log_ok()    { echo "${C_OK}[OK]${C_RESET} $*"; }
log_warn()  { echo "${C_WARN}[WARN]${C_RESET} $*"; }
log_error() { echo "${C_ERROR}[ERROR]${C_RESET} $*" >&2; }
