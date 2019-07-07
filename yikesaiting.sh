#!/bin/bash
set -ex

################################################################################
# Check basic directories
################################################################################
pkg_path="$( cd "$( dirname "${BASH_SOURCE[0]-$0}" )" && pwd )"
src_dir=${pkg_path}/tool-base
tar_dir=${pkg_path}/tool-deps
rpm_dir=${pkg_path}/tool-deps
temp_dir=${pkg_path}/tempdir

if [[ ! -d ${src_dir} || ! -d ${tar_dir} || ! -d ${rpm_dir} ]]; then
  echo "required folders not found"
  exit 1
fi



################################################################################
# Extract and setup toolchain
################################################################################
rm -rf ${temp_dir}
mkdir -p ${temp_dir}
find ${rpm_dir} -name '*rpm' -exec sudo rpm -Uvh --nodeps {} \;

if [ ! -d ${temp_dir}/clang ]; then
  tar xf ${tar_dir}/clang+llvm-7.0.0-x86_64-linux-sles11.3.tar.xz -C ${temp_dir}
  ln -sf clang+llvm-7.0.0-x86_64-linux-sles11.3 ${temp_dir}/clang
fi
if [ ! -d ${temp_dir}/cmake ]; then
  tar xf ${tar_dir}/cmake-3.12.4-Linux-x86_64.tar.gz -C ${temp_dir}
  ln -sf cmake-3.12.4-Linux-x86_64 ${temp_dir}/cmake
fi
if [ ! -d ${temp_dir}/dependency-clang-x86_64-Linux/ ]; then
  tar xf ${tar_dir}/dependency-clang-x86_64-Linux.tar.gz -C ${temp_dir}
fi

export PATH=${temp_dir}/clang/bin:${temp_dir}/cmake/bin:$PATH
export LD_LIBRARY_PATH=${temp_dir}/clang/lib:$LD_LIBRARY_PATH

export CPATH=${temp_dir}/clang/include/c++/v1/
export LIBRARY_PATH=${temp_dir}/clang/lib
export CXXFLAGS='-stdlib=libc++'
export LDFLAGS='-rtlib=compiler-rt -lgcc_s'

export CC=clang
export CXX=clang++
export LD=ld.lld
export LDSHARED="clang -shared"

source ${temp_dir}/dependency-clang-x86_64-Linux/package/env.sh



################################################################################
# Change install path
################################################################################
# sed -i "s|PREFIX=.*|PREFIX=${temp_dir}/dependency/package|" ${src_dir}/libhdfs3/build-all.sh
sed -i "s|PREFIX=.*|PREFIX=${temp_dir}/dependency/package|" ${src_dir}/hornet/build-all.sh
sed -i "s|DEPENDENCY_INSTALL_PREFIX=.*|DEPENDENCY_INSTALL_PREFIX=${temp_dir}/dependency/package|"  ${src_dir}/hornet/build-all.sh
export DEPENDENCY_PATH=${temp_dir}/dependency/package



################################################################################
# Build OushuDB
################################################################################
# make -C ${src_dir}/libhdfs3
export RUN_UNITTEST=no
make -j8 release -C ${src_dir}/hornet

cd ${src_dir}/hawq
make distclean || true
./configure --enable-orca --prefix=${temp_dir}/hawq
make skip-orca-build
make -j8
make -j8 install



################################################################################
# Package OushuDB
################################################################################
cp -rf ${temp_dir}/clang/lib/*c++*so* ${temp_dir}/hawq/lib/
cp -rf ${temp_dir}/dependency/package/lib/* ${temp_dir}/hawq/lib/
cp -rf ${temp_dir}/dependency-clang-x86_64-Linux/package/lib/* ${temp_dir}/hawq/lib/

cp -rf ${temp_dir}/dependency/package/bin/* ${temp_dir}/hawq/bin/
cp -rf ${temp_dir}/dependency-clang-x86_64-Linux/package/bin/python* ${temp_dir}/hawq/bin/
cp -rf ${temp_dir}/dependency-clang-x86_64-Linux/package/bin/lldb ${temp_dir}/hawq/bin/
cp -rf ${temp_dir}/dependency-clang-x86_64-Linux/package/bin/lldb-server ${temp_dir}/hawq/bin/
sed -i "s|GPHOME=.*|GPHOME=/usr/local/hawq|" ${temp_dir}/hawq/greenplum_path.sh

cd ${temp_dir} && tar czvf hawq.tar.gz hawq
