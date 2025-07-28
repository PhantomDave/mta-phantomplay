#!/bin/bash -x
#==============================================================================#
#                                mtasa-install                                 #
#------------------------------------------------------------------------------#
#  This shellscript installs MTA:SA on your server. You can configure it and   #
#  modify it as desired, you can even improve it if you want.                  #
#==============================================================================#
 
ARCH_TYPE=""
 
getArchitecture()
{
    if ((1<<32)); then
        ARCH_TYPE="_x64"
    fi
}
INSTALL_DIR="${INSTALL_DIR:-multitheftauto_linux${ARCH_TYPE}}"
 
downloadFiles()
{
    wget https://linux.multitheftauto.com/dl/multitheftauto_linux${ARCH_TYPE}.tar.gz
    wget https://linux.multitheftauto.com/dl/baseconfig.tar.gz
}
 
unpack()
{
    tar -xf multitheftauto_linux${ARCH_TYPE}.tar.gz
    tar -xf baseconfig.tar.gz
}
 
moveConfig()
{
    mv baseconfig/* "$INSTALL_DIR/mods/deathmatch"
    rm -rf baseconfig
    cd "$INSTALL_DIR"
}
 
installResources()
{
    mkdir mods/deathmatch/resources
    cd mods/deathmatch/resources
    wget https://mirror.multitheftauto.com/mtasa/resources/mtasa-resources-latest.zip
    unzip mtasa-resources-latest.zip
    cd ../../..
}
 
clean()
{
    rm -f ../multitheftauto_linux${ARCH_TYPE}.tar.gz
    rm -f ../baseconfig.tar.gz
    rm -f mods/deathmatch/resources/mtasa-resources-latest.zip
}
 
main()
{
    getArchitecture
    clean
    downloadFiles
    unpack
    moveConfig
    installResources
    clean
 
    if ((1<<32)); then # 64 bits
        echo "Installation ready! Use ./mta-server64 to initialize server"
    else
        echo "Installation ready! Use ./mta-server to initialize server"
    fi
}
 
main # calling program entry point