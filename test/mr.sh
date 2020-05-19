#!/usr/bin/env bash
set -euxo pipefail
TEST_DIR=$(mktemp -d -p /srv/jenkins)
mkdir -p "$TEST_DIR"
function finish() {
	rm -rf "$TEST_DIR"
}
trap finish EXIT
rsync --exclude 'mr.vcsh' \
	-av .config "$TEST_DIR"
cat <<EOF >"$TEST_DIR/.mrconfig"
[DEFAULT]
git_gc = git gc "$@"
jobs = 5
include = find -L $TEST_DIR/.config/mr/available.d -type f -exec cat '{}' \+
EOF
cd "$TEST_DIR" && HOME="$TEST_DIR" mr -j 3 --trust-all checkout --directory "$TEST_DIR"
