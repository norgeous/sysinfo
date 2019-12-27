#!/bin/bash

socat -vv TCP-LISTEN:9009,crlf,reuseaddr,fork SYSTEM:"echo HTTP/1.0 200; echo Content-Type\: text/plain; echo; sysinfo -ej" 2> /dev/null
