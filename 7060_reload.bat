:: This is a start script for Creo
:: It copies relevant config and start files from the engineering drive to local
:: It also starts the Creo software
:: It is the standard way to start a session of Creo
:: 
:: Author: Jacob Kane
:: Author date: 04-Mar-2022
:: Last Edit: -
:: Change Log: -


ECHO OFF
COLOR 7

:: Copy 7060_Reload.bat
xcopy /s/e/y "\\SBLPWIC011\Engineering\PTC\Config_beta\7060_Reload.bat" "C:\Program Files\PTC\Creo 7.0.6.0\Parametric\bin\"

:: Copy PSF files to local
xcopy /s/e/y "\\1\Engineering\PTC\Config\admin_C6\aa_basic.psf" "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\"
xcopy /s/e/y "\\1\Engineering\PTC\Config\admin_C6\advanced_assembly.psf" "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\"
xcopy /s/e/y "\\1\Engineering\PTC\Config\admin_C6\parametric.psf" "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\"
xcopy /s/e/y "\\1\Engineering\PTC\Config\admin_C6\z_aa_basic_no_windchill.psf" "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\"
xcopy /s/e/y "\\1\Engineering\PTC\Config\admin_C6\z_advanced_assembly_no_windchill.psf" "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\"
xcopy /s/e/y "\\1\Engineering\PTC\Config\admin_C6\z_parametric_no_windchill.psf" "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\"
xcopy /s/e/y "\\1\Engineering\PTC\Config\admin_C6\zz_parametric_Bloomington.psf" "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\"
xcopy /s/e/y "\\1\Engineering\PTC\Config\admin_C6\zz_parametric_Bloomington_no_windchill.psf" "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\"

:: Delete Test PSF Files
:: del "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\test.psf"
:: del "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\test.bat"

:: Copy Config files to local
xcopy /s/e/y "\\1\Engineering\PTC\Config\admin_C6\config.sup" "C:\Program Files\PTC\Creo 6.0.4.0\Common Files\text\"
xcopy /s/e/y "\\1\Engineering\PTC\Config\admin_C6\config.pro" "C:\Program Files\PTC\Creo 6.0.4.0\Common Files\text\"


::Copy start files to local
xcopy /s/e/y "\\1\Engineering\PTC\Config\creo6\start_files" "C:\creo6\start_files\"


:: Copy Creo Start Icon
:: This will be commented out for now, but will remain here in case changes are needed
copy  "\\1\Engineering\PTC\Config\CREO_OST_6040.lnk" "c:\USERs\%USERNAME%\DESKTOP\"


:: Start Creo Session
start "" "C:\creo6\start_files\Creo_Start.lnk"
::start "" "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PTC\Creo Parametric 6.0.4.0.lnk"

  
ECHO.
ECHO  ________________________________
ECHO  __  ____/__  __ \__  ____/_  __ \
ECHO  _  /    __  /_/ /_  __/  _  / / /
ECHO  / /___  _  _  _/_  /___  / /_/ /
ECHO  \____/  /_/ ^|_^| /_____/  \____/
ECHO.
ECHO CREO 6.0.4.0 START SCRIPT
ECHO   
ECHO.

COLOR 2

timeout 15
