#!/bin/bash
source /opt/dependency-6.0/package/env.sh || true
source /usr/local/gpdb/greenplum_path.sh || true
cd ~/dev/gpdb || cd ~/dev/gpdb7-oushudb6

cmake --build build/cmake-debug --target feature-test
if [[ -z $1 ]]; then
./build/cmake-debug/src/test/feature/feature-test --gtest_list_tests |
  perl -pe 's/#.*//' |
  awk '$1 ~ /\./ {kk=$1; print "\033[33m" kk "\033[0m"}; $1 !~ /\./  {print "  " kk $1}'
fi

export FEATURE_TEST_ROOT_DIR=$PWD/src/test/feature/
export SUPERUSER=$USER
[[ -z $1 ]] || ./build/cmake-debug/src/test/feature/feature-test --gtest_filter=$1
