#!/usr/bin/env bash

set -ex

# Step 1: Check go env
PROGRAM=$(basename "$0")
if [ -z "$(go env GOPATH)" ]; then
  printf "Error: the environment variable GOPATH is not set, please set it before running %s\n" "$PROGRAM" >/dev/stderr
  exit 1
fi

GOPATH=$(go env GOPATH)
PATH=$(pwd)/tools/bin:$GOPATH/bin:$PATH
export PATH

# Step 2: Install protobuf tools
echo "install tools..."
cd tools && make && cd ..

# Step 3: Collect pb files
function collect() {
  file=$(basename "$1")
  base_name=$(basename "$file" ".proto")
  mkdir -p ../pkg/"$base_name"
  if [ -z "$GO_OUT_M" ]; then
    GO_OUT_M="M$file=/"
  else
    GO_OUT_M="$GO_OUT_M,M$file=/"
  fi
}

cd proto
for f in *.proto; do
  [[ -e "$f" ]] || break # handle the case of no *.proto files
  collect "$f"
done

# Step 4: Generate pb
function gen() {
  base_name=$(basename "$1" ".proto")
  protoc -I.:../include --go_out=plugins=grpc,"$GO_OUT_M":../pkg/"$base_name" "$1" || ret=$?
  cd ../pkg/"$base_name"
  cd ../../proto
}

echo "generate go code..."
ret=0

for file in *.proto; do
  [[ -e "${file}" ]] || break
  gen "$file"
done

exit $ret
