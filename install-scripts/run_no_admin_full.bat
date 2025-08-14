C:
wsl -s Ubuntu
wsl --user root sh -c "cd /home/zso/ && mkdir usb"
pause
wsl --user root sh -c "cd /home/zso/ && mount -t drvfs %~d0 usb"
pause
wsl --user root sh -c "cd /home/zso/usb && sh install.sh"
pause
powershell start-process %~d0\runshort.bat -verb runas
powershell -Command %~d0\short.ps1
pause
