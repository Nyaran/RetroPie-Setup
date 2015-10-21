#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="opentyrian"
rp_module_desc="Open Tyrian, port of the DOS shoot-em-up Tyrian"
rp_module_menus="4+"
rp_module_flags="dispmanx"

function depends_opentyrian() {
    getDepends libsdl1.2-dev libsdl-net1.2-dev mercurial
}

function sources_opentyrian() {
    hg clone https://bitbucket.org/opentyrian/opentyrian "$md_build"
    # don't replace our CFLAGS
    sed -i "s/CFLAGS := -pedantic/CFLAGS += -pedantic/" Makefile
}

function build_opentyrian() {
    rpSwap on 512
    make clean
    make
    rpSwap off
    md_ret_require="$md_build/opentyrian"
}

function install_opentyrian() {
    make install prefix="$md_inst"
}

function configure_opentyrian() {
    mkRomDir "ports/opentyrian"

    # get Tyrian 2.1 (freeware game data)
    wget -q -O tyrian21.zip http://www.camanis.net/tyrian/tyrian21.zip
    unzip -j -o tyrian21.zip -d "$romdir/ports/opentyrian/data"
    rm -f tyrian21.zip

    cat > "$romdir/ports/OpenTyrian.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 0 "$md_inst/bin/opentyrian --data $romdir/ports/opentyrian/data" "$md_id"
_EOF_

    # Set startup script permissions
    chmod +x "$romdir/ports/OpenTyrian.sh"
    chown $user:$user "$romdir/ports/OpenTyrian.sh"

    # Enable dispmanx by default.
    setDispmanx "$md_id" 1

    # Add OpenTyrian to EmulationStation
    setESSystem 'Ports' 'ports' '~/RetroPie/roms/ports' '.sh .SH' '%ROM%' 'pc' 'ports'
}