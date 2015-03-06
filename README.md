# calibre_fetch_news
Calibre fetch news auto for Windows

This script is the revisiting of the original script for Bash https://gist.github.com/rogeliodh/1560289.
This work on Windows with PowerShell.

How use:
From PowerShell: .\calibre_fetch_news.ps1 -fileConfig calibre_fetch_news.cfn -recipe ilfatto

For Schedule task:
Program: powershell.exe
Arguments:
-NoProfile -NonInteractive -Command  "& 'e:\calibre_fetch_news\calibre_fetch_news.ps1' -fileConfig 'e:\calibre_fetch_news\calibre_fetch_news.cfn' -recipe 'ilfatto'" >e:\calibre_fetch_news\log.txt