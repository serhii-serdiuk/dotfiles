#!/bin/bash

PROJECT_PATH=$1
QML_FILE_NAME=$2
IDE_EXEC="$3"

# https://stackoverflow.com/a/16595367
QML_FILE_PATH=$(find "$PROJECT_PATH" -not \( -path "$PROJECT_PATH/build" -prune \) -not \( -path "$PROJECT_PATH/install" -prune \) -name "$QML_FILE_NAME.qml" -o -name "$QML_FILE_NAME.h" -o -name "$QML_FILE_NAME.hpp")

echo $PROJECT_PATH
echo $QML_FILE_NAME
echo $QML_FILE_PATH
echo $IDE_EXEC

$IDE_EXEC $QML_FILE_PATH
