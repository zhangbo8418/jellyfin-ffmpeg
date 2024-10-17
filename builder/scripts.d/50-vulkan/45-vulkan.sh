#!/bin/bash

SCRIPT_REPO="https://github.com/KhronosGroup/Vulkan-Headers.git"
SCRIPT_COMMIT="v1.3.298"
SCRIPT_TAGFILTER="v?.*.*"

ffbuild_enabled() {
    [[ $TARGET == mac* ]] && return -1
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" vkheaders
    cd vkheaders

    mkdir build && cd build

    cmake -GNinja -DCMAKE_TOOLCHAIN_FILE="$FFBUILD_CMAKE_TOOLCHAIN" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$FFBUILD_PREFIX" ..
    ninja -j$(nproc)
    ninja install

    cat >"$FFBUILD_PREFIX"/lib/pkgconfig/vulkan.pc <<EOF
prefix=$FFBUILD_PREFIX
includedir=\${prefix}/include

Name: vulkan
Version: ${SCRIPT_COMMIT:1}
Description: Vulkan (Headers Only)
Cflags: -I\${includedir}
EOF
}

ffbuild_configure() {
    echo --enable-vulkan
}

ffbuild_unconfigure() {
    echo --disable-vulkan
}
