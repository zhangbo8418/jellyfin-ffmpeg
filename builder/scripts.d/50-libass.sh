#!/bin/bash

SCRIPT_REPO="https://github.com/libass/libass.git"
SCRIPT_COMMIT="6a759836e5e76bb7b69b0ac244eea76b0d290512"

ffbuild_enabled() {
    return 0
}

ffbuild_dockerbuild() {
    git-mini-clone "$SCRIPT_REPO" "$SCRIPT_COMMIT" ass
    cd ass

    ./autogen.sh

    local myconf=(
        --prefix="$FFBUILD_PREFIX"
        --disable-shared
        --enable-static
        --with-pic
    )

    if [[ $TARGET == win* || $TARGET == linux* ]]; then
        myconf+=(
            --host="$FFBUILD_TOOLCHAIN"
        )
    elif [[ $TARGET == mac* ]]; then
        :
    else
        echo "Unknown target"
        return -1
    fi

    export CFLAGS="$CFLAGS -Dread_file=libass_internal_read_file"

    ./configure "${myconf[@]}"
    make -j$(nproc)
    make install
}

ffbuild_configure() {
    echo --enable-libass
}

ffbuild_unconfigure() {
    echo --disable-libass
}
