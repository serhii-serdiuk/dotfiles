#!/bin/bash

# Qt
cp -u ~/CraftRoot/build/libs/qt6/qtbase/image-RelWithDebInfo-*/lib/libQt6*.so.* ~/CraftRoot/lib/
cp -u ~/CraftRoot/build/libs/qt6/qtdeclarative/image-RelWithDebInfo-*/lib/libQt6*.so.* ~/CraftRoot/lib/

cp -r -u ~/CraftRoot/build/libs/qt6/qtbase/image-RelWithDebInfo-*/plugins/ ~/CraftRoot/
cp -r -u ~/CraftRoot/build/libs/qt6/qtsvg/image-RelWithDebInfo-*/plugins/ ~/CraftRoot/
cp -r -u ~/CraftRoot/build/libs/qt6/qtdeclarative/image-RelWithDebInfo-*/plugins/ ~/CraftRoot/

# OpenCV
cp -u ~/CraftRoot/build/libs/opencv/opencv/image-RelWithDebInfo-*/lib/libopencv_*.so.* ~/CraftRoot/lib/

# Other libs
cp -u ~/CraftRoot/build/libs/icu/image-RelWithDebInfo-*/lib/libicu*.so.* ~/CraftRoot/lib/
cp -u ~/CraftRoot/build/libs/gettext/image-RelWithDebInfo-*/lib/libintl.so.* ~/CraftRoot/lib/
cp -u ~/CraftRoot/build/libs/iconv/image-RelWithDebInfo-*/lib/libiconv.so.* ~/CraftRoot/lib/
cp -u ~/CraftRoot/build/libs/protobuf/image-RelWithDebInfo-*/lib/libprotobuf.so.* ~/CraftRoot/lib/
cp -u ~/CraftRoot/build/libs/protobuf/image-RelWithDebInfo-*/lib/libutf8_validity.so.* ~/CraftRoot/lib/
cp -u ~/CraftRoot/build/libs/abseil-cpp/image-RelWithDebInfo-*/lib/libabsl_*.so.* ~/CraftRoot/lib/
