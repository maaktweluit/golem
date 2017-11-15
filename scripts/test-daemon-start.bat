
echo "Starting hyperg"
start hyperg.exe

for /F "TOKENS=1,2,*" %a in ('tasklist /FI "IMAGENAME eq hyperg.exe"') do set H_PID=%b
echo %H_PID% > .test-daemon-hyperg.pid

exit 0
