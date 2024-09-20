SET REMOTE_BASE="\\dbmg0162\transfer\CreoInstalls"
SET CREO_VER="6.0.4.0"

%REMOTE_BASE%\MED-100WIN-CD-430_%CREO_VER:.=-%_Win64\setup.exe -xml "%REMOTE_BASE%\xml\creobase.p.xml"-xml "%REMOTE_BASE%\xml\pma.p.xml"

robocopy "%REMOTE_BASE%\Global license\" "C:\Program Files\PTC\Creo %CREO_VER%\Parametric\bin\" *.psf /zb

del "C:\Users\Public\Desktop\Creo Modelcheck %CREO_VER%.lnk"
copy "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PTC\Creo Parametric %CREO_VER%.lnk" "C:\Users\Public\Desktop\"

pause