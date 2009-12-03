#####
# A CMake build file for bp::file stuff.
# 
# Copyright 2009, Yahoo!
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
# 
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
# 
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in
#     the documentation and/or other materials provided with the
#     distribution.
# 
#  3. Neither the name of Yahoo! nor the names of its
#     contributors may be used to endorse or promote products derived
#     from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
# HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
# IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
# 
# Original Author: Gordon Durand
#####

cmake_minimum_required(VERSION 2.6)

INCLUDE(../build_support/BuildConfigs.cmake)

PROJECT(bp-file)

# default to a debug build.  This gets us symbols by default under
# the cmake makefile generator
#
IF (NOT CMAKE_BUILD_TYPE)
  SET(CMAKE_BUILD_TYPE "Debug")
ENDIF ()

INCLUDE_DIRECTORIES(
  "${CMAKE_CURRENT_SOURCE_DIR}/../external/${CMAKE_SYSTEM_NAME}/include"
)
 
LINK_DIRECTORIES(
  "${CMAKE_CURRENT_SOURCE_DIR}/../external/${CMAKE_SYSTEM_NAME}/lib"
  "${CMAKE_CURRENT_SOURCE_DIR}/../external/${CMAKE_SYSTEM_NAME}/lib/${CMAKE_BUILD_TYPE}"
)
 
IF (WIN32)
   SET(OS_SRCS bpfile_Windows.cpp)
ELSE ()
   SET(OS_SRCS bpfile_UNIX.cpp)
ENDIF ()
SET(SRCS bpfile.cpp ${OS_SRCS})
SET(HDRS api/bpfile.h)

# Alas, trying to test CMAKE_CONFIGURATION_TYPES doesn't work,
# it returns "Debug;Release" even for a single config generator
#
IF (CMAKE_CFG_INTDIR STREQUAL "." OR CMAKE_CFG_INTDIR STREQUAL "/")
   # using a single configuration generator
   SET(LINK_SUBDIR "${CMAKE_BUILD_TYPE}")
ELSE ()
   # using a multiple configuration generator
   # vs and xcode append a build type
   SET(LINK_SUBDIR "")
ENDIF ()

# boost libs
#
IF (WIN32)
   # Visual Studio does some autolink magic with boost, no need
   # to specify library
ELSE ()
#   SET(BOOST_LIBS "boost_filesystem" "boost_system")
ENDIF ()

ADD_LIBRARY(bpfile_s STATIC ${HDRS} ${SRCS})

SET(OS_LIBS)
IF (APPLE)
   # need carbon headers and library
   FIND_LIBRARY(CARBON_LIBRARY Carbon)
   MARK_AS_ADVANCED(CARBON_LIBRARY)
   SET(OS_LIBS ${CARBON_LIBRARY})
ENDIF() 

TARGET_LINK_LIBRARIES(bpfile_s ${BOOST_LIBS} ${OS_LIBS})


