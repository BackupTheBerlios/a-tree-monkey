#!/bin/sh
OUTPUT="$1"
XSL="$2"
INPUT="$3"
PARAM1_NAME="$4"
PARAM1_VALUE="$5"

xsltproc --stringparam "${PARAM1_NAME}" "${PARAM1_VALUE}" -o "${OUTPUT}" "${XSL}" "${INPUT}"
