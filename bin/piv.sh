#!/bin/bash

# https://elinux.org/RPi_HardwareHistory
# https://www.raspberrypi.org/documentation/hardware/raspberrypi/revision-codes/README.md
# This script was last updated in 2020

VERSION_CSV="
Revision,Release Date,Model,PCB Revision,Memory,Notes
Beta,Q1 2012,B (Beta),?,256MB,Beta Board
0002,Q1 2012,B,1.0,256MB
0003,Q3 2012,B (ECN0001),1.0,256MB,Fuses mod and D14 removed
0004,Q3 2012,B,2.0,256MB,(Manufactured by Sony UK)
0005,Q4 2012,B,2.0,256MB,(Manufactured by Qisda)
0006,Q4 2012,B,2.0,256MB,(Manufactured by Egoman)
0007,Q1 2013,A,2.0,256MB,(Manufactured by Egoman)
0008,Q1 2013,A,2.0,256MB,(Manufactured by Sony UK)
0009,Q1 2013,A,2.0,256MB,(Manufactured by Qisda)
000d,Q4 2012,B,2.0,512MB,(Manufactured by Egoman)
000e,Q4 2012,B,2.0,512MB,(Manufactured by Sony UK)
000f,Q4 2012,B,2.0,512MB,(Manufactured by Qisda)
0010,Q3 2014,B+,1.0,512MB,(Manufactured by Sony UK)
0011,Q2 2014,Compute Module 1,1.0,512MB,(Manufactured by Sony UK)
0012,Q4 2014,A+,1.1,256MB,(Manufactured by Sony UK)
0013,Q1 2015,B+,1.2,512MB,(Manufactured by Embest)
0014,Q2 2014,Compute Module 1,1.0,512MB,(Manufactured by Embest)
0015,Q? ????,A+,1.1,256MB/512MB,(Manufactured by Embest)
a01040,Q? ????,2B,1.0,1GB,(Manufactured by Sony UK)
a01041,Q1 2015,2B,1.1,1GB,(Manufactured by Sony UK)
a21041,Q1 2015,2B,1.1,1GB,(Manufactured by Embest)
a22042,Q3 2016,2B (with BCM2837),1.2,1GB,(Manufactured by Embest)
900021,Q3 2016,A+,1.1,512MB,(Manufactured by Sony UK)
900032,Q2 2016?,B+,1.2,512MB,(Manufactured by Sony UK)
900061,Q? ????,Compute Module,1.1,512MB,(Manufactured by Sony UK)
900092,Q4 2015,Zero,1.2,512MB,(Manufactured by Sony UK)
900093,Q2 2016,Zero,1.3,512MB,(Manufactured by Sony UK)
920092,Q? ????,Zero,1.2,512MB,(Manufactured by Embest)
920093,Q4 2016?,Zero,1.3,512MB,(Manufactured by Embest)
9000c1,Q1 2017,Zero W,1.1,512MB,(Manufactured by Sony UK)
a02082,Q1 2016,3B,1.2,1GB,(Manufactured by Sony UK)
a020a0,Q1 2017,Compute Module 3 (and CM3 Lite),1.0,1GB,(Manufactured by Sony UK)
a02042,Q? ????,2B (with BCM2837),1.2,1GB,(Manufactured by Sony UK)
a22082,Q1 2016,3B,1.2,1GB,(Manufactured by Embest)
a22083,Q? ????,3B,1.3,1GB,(Manufactured by Embest)
a220a0,Q? ????,Compute Module 3,1.0,1GB,(Manufactured by Embest)
a32082,Q4 2016,3B,1.2,1GB,(Manufactured by Sony Japan)
a52082,Q? ????,3B,1.2,1GB,(Manufactured by Stadium)
a020d3,Q1 2018,3B+,1.3,1GB,(Manufactured by Sony UK)
9020e0,Q4 2018,3A+,1.0,512MB,(Manufactured by Sony UK)
a02100,Q1 2019,Compute Module 3+,1.0,1GB,(Manufactured by Sony UK)
a03111,Q2 2019,4B,1.1,1GB,(Manufactured by Sony UK)
b03111,Q2 2019,4B,1.1,2GB,(Manufactured by Sony UK)
c03111,Q2 2019,4B,1.1,4GB,(Manufactured by Sony UK)
b03112,Q? 2020,4B,1.2,2GB,(Manufactured by Sony UK)
c03112,Q? 2020,4B,1.2,4GB,(Manufactured by Sony UK)
b03114,Q? 2020,4B,1.4,2GB,(Manufactured by Sony UK)
d03114,Q? 2020,4B,1.4,8GB,(Manufactured by Sony UK)
c03130,Q? 2020,Pi 400,1.0,4GB,(Manufactured by Sony UK)
"

THIS_VER=$(cat "/proc/cpuinfo" | grep "Revision" | cut -d" " -f2)
THIS_INFOLINE=$(echo "$VERSION_CSV" | grep "$THIS_VER")

THIS_DATE=$(echo "$THIS_INFOLINE" | cut -d"," -f2 )
THIS_MODEL=$(echo "$THIS_INFOLINE" | cut -d"," -f3 )
THIS_PCBREV=$(echo "$THIS_INFOLINE" | cut -d"," -f4 )
THIS_MEMORY=$(echo "$THIS_INFOLINE" | cut -d"," -f5 )
THIS_NOTES=$(echo "$THIS_INFOLINE" | cut -d"," -f6 )

echo -n "$THIS_MODEL $THIS_PCBREV"
[ "$1" == "-e" ] && echo -n " $THIS_MEMORY $THIS_NOTES $THIS_DATE"
echo
