# Defines BitShares library target.
project( Achain )
cmake_minimum_required( VERSION 2.8.12 )

#to supprot c++11, gcc must over version 4.8, clang over 3.3
# http://stackoverflow.com/a/18369825
if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU")
    if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 4.8)
        message(FATAL_ERROR "GCC version must be at least 4.8!")
    endif()
elseif ("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang")
    if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS 3.3)
        message(FATAL_ERROR "Clang version must be at least 3.3!")
    endif()
endif()

find_library(myReadlineLib NAMES readline)
find_path(myReadlineHead readline/readline.h)
if(NOT myReadlineLib OR NOT myReadlineHead)
  MESSAGE(FATAL_ERROR "Could not find lib readline.")
endif()

AUX_SOURCE_DIRECTORY(libraries/api API_SRC)
AUX_SOURCE_DIRECTORY(libraries/cli CLI_SRC)
AUX_SOURCE_DIRECTORY(libraries/client CLIENT_SRC)
AUX_SOURCE_DIRECTORY(libraries/db DB_SRC)
AUX_SOURCE_DIRECTORY(libraries/net NET_SRC)
AUX_SOURCE_DIRECTORY(libraries/rpc RPC_SRC)
AUX_SOURCE_DIRECTORY(libraries/rpc_stubs RPC_STUBS_SRC)
AUX_SOURCE_DIRECTORY(libraries/utilities UTILITIES_SRC)
AUX_SOURCE_DIRECTORY(libraries/wallet WALLET_SRC)
AUX_SOURCE_DIRECTORY(libraries/blockchain BLOCKCHAIN_SRC)
AUX_SOURCE_DIRECTORY(libraries/glua GLUA_SRC)
LIST(REMOVE_ITEM BLOCKCHAIN_SRC "libraries/blockchain/applink.c")
LIST(REMOVE_ITEM GLUA_SRC "libraries/glua/main.cpp" "libraries/glua/cdemo1.cpp" "libraries/glua/Achain_lua_api.demo.cpp")

if( APPLE )
    # Apple Specific Options Here
    message( STATUS "Configuring BitShares on OS X" )
    set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -std=c++11 -stdlib=libc++ -Wall")
    #set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -std=c++11 -stdlib=libc++ -Wall -DALP_GLOBAL_API_LOG=1 -fpermissive" )

    #SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -Wall")
    #SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11 -stdlib=libc++ -Wall")
    #SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DWEBSOCKETPP_STRICT_MASKING")
    #SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DBOOST_ASIO_HAS_STD_CHRONO")
    #SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DALP_GLOBAL_API_LOG=1 -fpermissive" )

    #SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++0x -Wall -Wno-unused-local-typedefs -fmax-errors=3 -msse4.2" ) 
    #SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99 -Wall -Wno-unused-local-typedefs -fmax-errors=3 -msse4.2" )
else( APPLE )
    # Linux Specific Options Here
    message( STATUS "Configuring Achain on Linux" )
    SET (CMAKE_CXX_COMPILER     "/usr/bin/g++")
    set( CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -g -std=c++11 -Wall -DALP_GLOBAL_API_LOG=1 -fpermissive" )
    set( rt_library rt )
    set( pthread_library pthread)
    if ( NOT DEFINED crypto_library )
      # I'm not sure why this is here, I guess someone has openssl and can't detect it with find_package()?
      # if you have a normal install, you can define crypto_library to the empty string to avoid a build error
      set( crypto_library crypto)
    endif ()
    if ( FULL_STATIC_BUILD )
      set( CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libstdc++ -static-libgcc")
    endif ( FULL_STATIC_BUILD )
endif( APPLE )

if( "${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" )
    set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fno-builtin-memcmp" )
elseif( "${CMAKE_CXX_COMPILER_ID}" STREQUAL "Clang" )
    if( CMAKE_CXX_COMPILER_VERSION VERSION_EQUAL 4.0.0 OR CMAKE_CXX_COMPILER_VERSION VERSION_GREATER 4.0.0 )
        set( CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-invalid-partial-specialization" )
    endif()
endif()

# Boost settings
set(Boost_USE_STATIC_LIBS     ON)
set(Boost_USE_MULTITHREADED   ON)
set(Boost_USE_STATIC_RUNTIME  ON)

# Specify Boost libraries that will use.
 FIND_PACKAGE( Boost 1.54.0 REQUIRED COMPONENTS system program_options chrono context coroutine date_time exception filesystem iostreams locale thread )

#FIND_PACKAGE( Boost 1.53.0 REQUIRED COMPONENTS system program_options chrono context coroutine date_time           filesystem                  thread  signals serialization unit_test_framework ) 

#FIND_PACKAGE( Boost 1.53.0 REQUIRED COMPONENTS thread date_time system filesystem program_options signals serialization chrono unit_test_framework context coroutine) 
#set( BOOST_LIBRARIES ${Boost_THREAD_LIBRARY} ${Boost_SYSTEM_LIBRARY} ${Boost_FILESYSTEM_LIBRARY} ${Boost_DATE_TIME_LIBRARY} ${Boost_CHRONO_LIBRARY} ${ALL_OPENSSL_LIBRARIES} ${Boost_COROUTINE_LIBRARY} ${Boost_CONTEXT_LIBRARY} ${pthread})

MESSAGE(STATUS “BOOST : ${Boost_LIBRARIES}”)

set(CMAKE_CXX_FLAGS "-std=c++11 -DALP_GLOBAL_API_LOG=1 -fpermissive" )
#set(Boost_INCLUDE_DIR　"/usr/include/boost")
set(Boost_INCLUDE_DIR　"/usr/local/include/boost")
#set(Boost_LIBRARY_DIR  "/usr/lib/x86_64-linux-gnu")
set(Boost_LIBRARY_DIR  "/usr/local/lib")

INCLUDE_DIRECTORIES(
        "/usr/local/Cellar/openssl/1.0.2m/include/"
        ${Boost_INCLUDE_DIR} 
        "./libraries/include"
        "../include"
)

LINK_DIRECTORIES( ${Boost_LIBRARY_DIR}
         "./"
        "/usr/local/lib"
        "libraries/api"
        "libraries/blockchain"
        "libraries/utilities"
        "libraries/cli"
        "libraries/client"
        "libraries/db"
        "libraries/glua"
        "libraries/net"
        "libraries/rpc"
        "libraries/rpc_stubs"
        "libraries/wallet"
)

set(SOURCE_FILES Main.cpp)
add_executable(Achain ${SOURCE_FILES})
#TARGET_LINK_LIBRARIES(Achain libtotal.a libglua.a fc libsecp256k1.a libleveldb.a libminiupnpc.a ${Boost_LIBRARIES} libcrypto.a dl)
TARGET_LINK_LIBRARIES(Achain libtotal.a libglua.a /usr/local/lib/libfc.a /usr/local/lib/libsecp256k1.a libleveldb.a /usr/local/lib/libminiupnpc.a ${Boost_LIBRARIES} /usr/local/Cellar/openssl/1.0.2m/lib/libcrypto.a dl)

add_library(fc STATIC IMPORTED)
set_target_properties(fc PROPERTIES  IMPORTED_LOCATION /usr/local/lib/libfc.a)

add_library(glua ${GLUA_SRC})
set_target_properties(glua PROPERTIES  IMPORTED_LOCATION_RELEASE ./libglua.a  IMPORTED_LINK_INTERFACE_LIBRARIES fc)

add_library(total ${API_SRC} ${BLOCKCHAIN_SRC} ${CLI_SRC} ${CLIENT_SRC} ${DB_SRC} ${NET_SRC} ${RPC_SRC} ${RPC_STUBS_SRC} ${UTILITIES_SRC} ${WALLET_SRC})
set_target_properties(total PROPERTIES  IMPORTED_LOCATION_RELEASE ./libtotal.a  IMPORTED_LINK_INTERFACE_LIBRARIES fc)

#set(SOURCE_FILES Main.cpp)
#add_executable(Achain ${SOURCE_FILES})
#TARGET_LINK_LIBRARIES(Achain libtotal.a libglua.a fc libsecp256k1.a libleveldb.a libminiupnpc.a ${Boost_LIBRARIES} libcrypto.a dl)
#TARGET_LINK_LIBRARIES(Achain libtotal.a libglua.a /usr/local/lib/libfc.a libsecp256k1.a libleveldb.a libminiupnpc.a ${Boost_LIBRARIES} libcrypto.a dl)
