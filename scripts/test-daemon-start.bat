
echo "Starting hyperg"
start hyperg.exe

for /F "TOKENS=2" %a in ('tasklist /nh /fi "IMAGENAME eq hyperg.exe"') do set H_PID=%a
echo %H_PID% > .test-daemon-hyperg.pid

exit 0
