#!/bin/sh
# mac_installation_guide
# befor compile, make sure you have installed dependent packages in your system
# for MacOs systems, do as following
# mac
# pre-installation:
# install denpendancy packages
#  >>>> brew install automake autoconf libtool autotools cmake git openssl readline curl 
#       brew link --force openssl readline curl
#-------------------------------------------------------------------------------------------             
#    NOTE： Manually install Boost 1.59 and openssl 1.0.2k into default /usr/local directory             
#     1).  install boost 1.59 
#           curl -LO http://sourceforge.net/projects/boost/files/boost/1.59.0/boost_1_59_0.tar.gz
#           tar -zxvf boost_1_59_0.tar.gz
#           cd boost_1_59_0
#           ./bootstrap.sh  
#           ./b2 cxxflags="-arch x86_64" linkflags="-arch x86_64"
#           ./b2 install
           
#     2). install openssl 1.0.2k
#           curl -LO https://www.openssl.org/source/old/1.0.2/openssl-1.0.2k.tar.gz
#           tar -zxvf openssl-1.0.2k.tar.gz
#           cd openssl-1.0.2k
#           ./Configure darwin64-x86_64-cc --prefix= xxx 
#           make depend
#           make install

#           details please refer to the WIKI(https://wiki.openssl.org/index.php/Compilation_and_Installation#OS_X)
#--------------------------------------------------------------------------------------------
#
echo "Warning: make sure you have installed dependent packages in your system"
echo "if not, pls read the buildall.sh and run the comment scripts in the beginning"
echo

while true; do
    read -p "Do you wish to continue building the program?[y/n] " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please enter yes or no.";;
    esac
done

if [ "$1" != "download" ]
then
    echo "Do not download sourcecode.  Isdownload=Nodownload"
    Isdownload=Nodownload
else
    Isdownload=$1
fi

currentpath=$(pwd)
leveldbpath=$currentpath/leveldb-1.20/
miniupnpcpath=$currentpath/miniupnpc-1.7.20120830/
leveldbtar=$currentpath/v1.20.tar.gz
miniupnpctar=$currentpath/miniupnpc-1.7.20120830.tar.gz
fc=$currentpath/fast-compile
blockchain=$currentpath/Chain

echo "build and  install the leveldb [1.18 or later]"
if [ "$Isdownload" = "download" ]
then
    echo "download leveldb version 1.20 [https://github.com/google/leveldb/releases]"
    curl -Lo v1.20.tar.gz https://github.com/google/leveldb/archive/v1.20.tar.gz
else
    echo "Do not download leveldb source files"
fi
echo

if [ -f $leveldbtar ]; then 
    echo "unzip leveldb source files"
    tar -zxvf v1.20.tar.gz
 else
    echo
fi

if [ -d "$leveldbpath" ]; then
    cd $leveldbpath
    make
    sudo scp out-static/lib*  /usr/local/lib/
    cd ..
else
    echo "Error: there are no related leveldb files, pls check ..."
fi

echo "build and install the miniupnpc [ only  1.7 ]"

if  [ "$Isdownload" = "download" ] ; then
    echo "download http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.7.20120830.tar.gz"
    curl -Lo miniupnpc-1.7.20120830.tar.gz http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.7.20120830.tar.gz
else
    echo "Do not download miniupnpc files"
fi

if [ -f $miniupnpctar ]; then 
    echo "unzip miniupnpc..."
    tar -zxvf miniupnpc-1.7.20120830.tar.gz
else
    echo
fi
if [ -d "$miniupnpcpath" ]; then
    cd $miniupnpcpath
    cmake .
    make
    sudo make install
    cd ..
else
    echo "Error: there are no related miniupnpc files, pls check ..."
fi 

echo "build fast-compile library..."
if  [ "$Isdownload" = "download" ] ; then
    git clone https://github.com/Achain-Dev/fast-compile.git
    cd fast-compile
    git submodule update --init --recursive
    git checkout static_variant_string_tag
else
    echo
fi
if [ -d "$fc" ]; then
    cd $fc
    cmake . [ -DOPENSSL_ROOT_DIR=xxx -DBOOST_ROOT_DIR=xxx] 
    make
    sudo cp libfc.a  /usr/local/lib/
    sudo cp $fc/vendor/secp256k1-zkp/src/project_secp256k1-build/.libs/libsecp256k1.a /usr/local/lib
    cd ..
else
    echo "Error: no related fast-compile files, pls check..."
fi

echo
echo "build Achain linux code..."
echo

if [ -d "$blockchain" ]; then
    cd $blockchain
    cmake .
    make
    cd ..
else
    echo "Error: no related Achain_linux files, pls check..."
fi

echo "Info: finished building work, pls move $blockchain/Achain to the running directory "

