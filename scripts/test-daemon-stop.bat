#!/bin/sh
H_FILE=.test-daemon-hyperg.pid
set /p H_PID=<%H_FILE%
del %H_FILE% || echo "Error, not able to delete '%H_FILE%'"

Taskkill /PID %H_PID% /F

exit 0
