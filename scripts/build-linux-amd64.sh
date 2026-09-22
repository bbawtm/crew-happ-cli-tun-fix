#!/usr/bin/env bash
set -euo pipefail

readonly happ_url='https://github.com/GenkaOk/happ-cli.git'
readonly happ_ref='v0.0.4'
readonly tun_url='https://github.com/xjasonlyu/tun2socks.git'
readonly tun_ref='v2.6.0'
readonly root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly workspace=$(mktemp -d)
trap 'rm -rf "$workspace"' EXIT

git clone --depth 1 --branch "$happ_ref" "$happ_url" "$workspace/happ-cli"
git clone --depth 1 --branch "$tun_ref" "$tun_url" "$workspace/happ-cli/third_party/tun2socks"
git -C "$workspace/happ-cli/third_party/tun2socks" apply "$root/patches/tun2socks-start-error.patch"
git -C "$workspace/happ-cli" apply "$root/patches/happ-cli-tun-error-propagation.patch"

(
  cd "$workspace/happ-cli"
  GOTOOLCHAIN=go1.26.4 go test ./...
)
(
  cd "$workspace/happ-cli/third_party/tun2socks"
  GOTOOLCHAIN=go1.26.4 go test ./engine
)
(
  cd "$workspace/happ-cli"
  GOTOOLCHAIN=go1.26.4 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags='-s -w' -o "$workspace/happ" ./cmd/happ
)

mkdir -p "$root/dist/happ-linux-amd64"
install -m 0755 "$workspace/happ" "$root/dist/happ-linux-amd64/happ"
tar -C "$root/dist" -czf "$root/dist/happ-linux-amd64.tar.gz" happ-linux-amd64
rm -rf "$root/dist/happ-linux-amd64"
