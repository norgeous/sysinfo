#!/bin/bash

socat -vv TCP-LISTEN:9009,crlf,reuseaddr,fork SYSTEM:"echo HTTP/1.0 200; echo Content-Type\: application/json; echo; sysinfo -ej"
