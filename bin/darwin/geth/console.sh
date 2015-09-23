#!/bin/sh

echo '
on run argv
  if length of argv is equal to 0
    set command to ""
  else
    set command to item 1 of argv
  end if
  runSimple(command)
end run

on runSimple(command)
  tell application "Terminal"
    activate
    set newTab to do script(command)
  end tell
  return newTab
end runSimple
' | osascript - "$@" > /dev/null
