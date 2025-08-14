wsl -s Ubuntu
wsl --user root sh -c "cd /home/zso/ && mkdir usb"
pause
wsl --user root sh -c "cd /home/zso/ && mount -t drvfs %~d0 usb"
pause
wsl --user root sh -c "cd /home/zso/usb && sh install.sh"
pause
powershell -Command Set-ExecutionPolicy unrestricted
powershell -Command %~d0\short.ps1
pause
