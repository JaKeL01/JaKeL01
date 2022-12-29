\\dbmg0162\transfer\CreoInstalls\MED-100WIN-CD-430_6-0-4-0_Win64\setup.exe -xml "\\dbmg0162\transfer\CreoInstalls\xml\creobase.p.xml"-xml "\\dbmg0162\transfer\CreoInstalls\xml\pma.p.xml"
pause
xcopy /s/e/y/d "\\dbmg0162\transfer\creoinstalls\Global license\aa_basic.psf" "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\"
xcopy /s/e/y/d "\\dbmg0162\transfer\creoinstalls\Global license\advanced_assembly.psf" "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\"
xcopy /s/e/y/d "\\dbmg0162\transfer\creoinstalls\Global license\parametric.psf" "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\"
xcopy /s/e/y/d "\\dbmg0162\transfer\creoinstalls\Global license\z_aa_basic_no_windchill.psf" "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\"
xcopy /s/e/y/d "\\dbmg0162\transfer\creoinstalls\Global license\z_advanced_assembly_no_windchill.psf" "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\"
xcopy /s/e/y/d "\\dbmg0162\transfer\creoinstalls\Global license\z_parametric_no_windchill.psf" "C:\Program Files\PTC\Creo 6.0.4.0\Parametric\bin\"
del "C:\Users\Public\Desktop\Creo Modelcheck 6.0.4.0.lnk"
copy "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PTC\Creo Parametric 6.0.4.0.lnk" C:\Users\Public\Desktop
pause
