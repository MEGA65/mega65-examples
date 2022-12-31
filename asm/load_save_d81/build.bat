@echo off
set FORMAT="c1541.exe" -format "disk,0" d81 "DEMO.D81"
set WRITE="c1541.exe" -attach "DEMO.D81" 8 -write

rm ./bin/main.prg
java -jar E:\KickAss\megakickass.jar -vicesymbols -showmem -odir /bin main.asm 

%FORMAT% && %WRITE% "./bin/main.prg" 
%WRITE% "./pal0.bin"
