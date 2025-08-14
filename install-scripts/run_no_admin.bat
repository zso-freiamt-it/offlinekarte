C:
wsl -s Ubuntu
wsl --user root sh -c "cd /home/zso/ && mkdir usb"
pause
wsl --user root sh -c "cd /home/zso/ && mount -t drvfs %~d0 usb"
pause
wsl --user root sh -c "cd /home/zso/usb && sh install.sh"
pause
