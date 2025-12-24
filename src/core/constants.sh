#!/usr/bin/env bash
set -euo pipefail
shopt -s globstar nullglob

APP_NAME="reprofed"
APP_PATH="/opt/$APP_NAME"
DNF="dnf5"
