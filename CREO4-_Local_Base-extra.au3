#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=parametric.ico
#AutoIt3Wrapper_Outfile=CreoStart4.0M100.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;updated MC location and added call home functionality
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <File.au3>

;Setting variables
Dim $user = EnvGet("USERNAME")
Dim $pcname = EnvGet("COMPUTERNAME")
Dim $start_dir = "C:\Data\Creo\" & $user ;-Default satrtup dir
Dim $homeDrivesU = "LYN" ;-U drive:
Dim $homeDrivesI = "ELC" ;-I drive:
Dim $notBossPcs = "LYN,BEA,XIA,RIV,ELC,SHO,TOM,WIN,ADL,ELP,SHA,SPB,ALT";- This should get the boss PCs for the most part.  Eventually hope to remove this...
Dim $updateCheckFile = "update4M100.txt";-name of file to check for updates
;Paths for checking for updates
Dim $localUpdateCheckFile = "c:\PTC\" & $updateCheckFile;-Local file that is read to do the copying
;Location for update file at each location
Dim $BEAupdateCheckLoc = "\\bea\Apps\EngApps\Install\updates\4M100\" & $updateCheckFile;
Dim $SPBupdateCheckLoc = "\\spb\PLocal\apps\install\updates\4M100\" & $updateCheckFile;
Dim $LYNupdateCheckLoc = "\\lyn\apps\EngApps\Install\updates\4M100\" & $updateCheckFile;
Dim $IROupdateCheckLoc = "\\iro\PTC-BOSS\Pro_std\updates\4M100\" & $updateCheckFile;
Dim $RIVupdateCheckLoc = "\\riv\Apps\EngApps\Install\updates\4M100\" & $updateCheckFile;
Dim $ELCupdateCheckLoc = "\\elc\apps\EngApps\Install\updates\4M100\" & $updateCheckFile;

Dim $UDrive = "u:\"
Dim $JDrive = "j:\"
Dim $IDrive = "i:\"
Dim $bkp_config_dir = "creo_config_backup" ;-This and the drive letter makeup the full path.
Dim $bkp_files = "*.cfg,*.scl,*.pro,*.ui,*.dmt,*.map" ;-These are the extension we look for to backup.
Dim $startcmd = "1" ; Default Command
Dim $mcDir = "C:\PTC\u\form\pro\mc"
;-the following are change for each version
Dim $icon = "C:\PTC\creo4.0M100\Creo 4.0\M100\Parametric\install\nt\creologo.ico"
Dim $creoProdPath = "C:\PTC\creo4.0M100\Creo 4.0\M100\Parametric\bin\" ;-besure to include the last \. Example end like this: (Parametric\bin\)
Dim $creoSimProdPath = "C:\PTC\creo4.0M100\Creo 4.0\M100\Simulate\bin\" ;-besure to include the last \. Example end like this: (Simulate\bin\)
Dim $Creoagent4Path = "C:\PTC\creo4.0M100\Creo\Agent\creoagent.exe" ;-no slash on end of path
Dim $Creoagent4List = "C:\PTC\creo4.0M100\Creo\Platform\4\manifests" ;-no slash on end of path
;~ If you use online help it makes you have a username and password on https://urldefense.com/v3/__http://support.ptc.com__;!!A16HtNeG!JNEa1k8-GL-Aqfwf6wgwhKLoqKhCLgvDUmIbz1CfjeSbA2J1dR3DYltIaMPq$ 
Dim $creoPMAHelp = "C:\PTC\creo4.0M100\Creo 4.0\help\creo_help_pma" ;-no slash on end of path
Dim $creoSIMHelp = "C:\PTC\creo4.0M100\Creo 4.0\help\creo_help_sim" ;-no slash on end of path
;-This sets the local cache dir.
Dim $pathtocache = @AppDataDir & "\PTC\ProENGINEER\.wfcreo4_2" ;-no slash on end of path
Dim $bypass_creo = "C:\Data\Creo\" & $user &"\bypass4M100.txt" ;-used to bypass startup menu
Dim $cmddir = "c:\windows\system32"

;~ Not Using right now
;~ Dim $Creoagent4Java = "C:\PTC\u\jlinkcreo\JRE\bin\java.exe"
;~ Dim $icon = EnvGet("SystemDrive") & "\Startup\ptc.ico" ;not using at this point.
;~ Dim $config_pro = "C:\Data\Creo\config.pro"
;~ EnvSet("PRO_JAVA_COMMAND", $Creoagent4Java)

EnvSet("PTC_SUPPRESS_RESTART_AWARE", "true") ;-supress dos comand prompt on start up for creo 3.0
EnvSet("mcdir", $mcDir) ;ModelCheck start-in dir
EnvSet("MPA_PROE_MESH_PARAM", "1")
EnvSet("PATH", StringTrimRight($creoProdPath, 1) & ";" & $cmddir) ;-using trim to remove \
EnvSet("CONTINUE_FROM_OOS", "1") ;-This vaiable stops pro/e from crashing when error in trail file

;- Local Help path - If you use online help it makes you have a username and password on https://urldefense.com/v3/__http://support.ptc.com__;!!A16HtNeG!JNEa1k8-GL-Aqfwf6wgwhKLoqKhCLgvDUmIbz1CfjeSbA2J1dR3DYltIaMPq$ 
EnvSet("PTC_PMA_HC_URL_4", $creoPMAHelp)
EnvSet("PTC_SIM_HC_URL_4", $creoSIMHelp)

;-Envionment vairables to run Creoagent on server - Also remember tochange the https://urldefense.com/v3/__http://config.pro__;!!A16HtNeG!JNEa1k8-GL-Aqfwf6wgwhKLoqKhCLgvDUmIbz1CfjeSbA2J1dR3DYuyRy6tH$  for quality agent.
EnvSet("CREO_AGENT_EXE_PATH", $Creoagent4Path)
EnvSet("CREO_AGENT_LDP_LIST", $Creoagent4List)

;~ Reference CS185244 for details on this variable
EnvSet("PROTK_DELAYINIT_ALWAYS_INIT", "TRUE");


;Done setting variables

;-this checks the what drives are avaiable
Dim $getpath = checkDirs() ;

;-This copies the files depending on status
Dim $copyFiles = copyFiles($getpath) ;

callHome();
updatefile();

If FileExists($bypass_creo) Then
	Trailfile()
	QA_Map()
	EnvSet("PTC_WF_ROOT", $pathtocache)
	ShellExecute($creoProdPath & "creoprod.bat", "", $start_dir, "open")
	Exit
EndIf


Local $default1, $default2, $startcmd, $Radio1, $Radio8, $Radio9, $Checkbox1, $CREO4_M100

#Region ### START Koda GUI section ### Form=g:\engapps\startup\creo4-m010.kxf
$CREO4_M100 = GUICreate("PTC Creo 4 M100 Startup LL.4.100.1", 601, 375, 192, 124)
GUISetBkColor(0x5BB73B)
GUISetIcon($icon, 0)
$Label1 = GUICtrlCreateLabel("CREO 4 M100 Startup Menu", 90, 40, 461, 41)
GUICtrlSetFont(-1, 24, 800, 0, "Arial")
GUICtrlSetColor(-1, 0x000000)
GUICtrlSetFont(-1, 24, 800, 0, "Arial")
$Group1 = GUICtrlCreateGroup("", 88, 72, 425, 216)
GUICtrlSetColor(-1, 0xFFFFFF)
$Radio1 = GUICtrlCreateRadio("CREO Parametrics (Default) - Includes IFX", 104, 88, 350, 30)
GUICtrlSetState(-1, $GUI_CHECKED)
GUICtrlSetFont(-1, 12, 800, 0, "Arial")
$Radio2 = GUICtrlCreateRadio("CREO Parametric Extensions (ISDX / BMX / MDO)", 104, 120, 393, 30)
GUICtrlSetFont(-1, 12, 800, 0, "Arial")
$Radio3 = GUICtrlCreateRadio("CREO Plastic Advisor", 104, 152, 193, 30)
GUICtrlSetFont(-1, 12, 800, 0, "Arial")
$Radio4 = GUICtrlCreateRadio("CREO Manikin", 104, 184, 193, 30)
GUICtrlSetFont(-1, 12, 800, 0, "Arial")
;~ $Radio5 = GUICtrlCreateRadio("CREO Advanced Rendering", 104, 216, 242, 30)
;~ GUICtrlSetFont(-1, 12, 800, 0, "Arial")
$Radio6 = GUICtrlCreateRadio("CREO Design Exploration", 104, 216, 242, 30)
GUICtrlSetFont(-1, 12, 800, 0, "Arial")
$Radio8 = GUICtrlCreateRadio("CREO Simulate", 104, 248, 218, 30)
GUICtrlSetFont(-1, 12, 800, 0, "Arial")
GUICtrlCreateGroup("", -99, -99, 1, 1)
$Button1 = GUICtrlCreateButton("Launch", 200, 308, 200, 33)
GUICtrlSetFont(-1, 12, 800, 0, "Arial")
$Checkbox1 = GUICtrlCreateCheckbox("Don't display this Menu again. Start Creo with defaults.", 8, 346, 365, 17)
GUICtrlSetFont(-1, 10, 800, 0, "Arial")
GUICtrlSetTip(-1, "This option will enable the ability to start Creo with default options and turn off this menu.")
GUISetState(@SW_SHOW)
GUICtrlSetState($Button1, $GUI_FOCUS)
#EndRegion ### END Koda GUI section ##

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $Radio1
			$startcmd = "1"
			GUICtrlSetState($Button1, $GUI_FOCUS)
		Case $Radio2
			$startcmd = "2"
			GUICtrlSetState($Button1, $GUI_FOCUS)
		Case $Radio3
			$startcmd = "3"
			GUICtrlSetState($Button1, $GUI_FOCUS)
		Case $Radio4
			$startcmd = "4"
			GUICtrlSetState($Button1, $GUI_FOCUS)
;~ 		Case $Radio5
;~ 			$startcmd = "5"
;~ 			GUICtrlSetState($Button1, $GUI_FOCUS)
		Case $Radio6
			$startcmd = "6"
			GUICtrlSetState($Button1, $GUI_FOCUS)
		Case $Radio8
			$startcmd = "8"
			GUICtrlSetState($Button1, $GUI_FOCUS)
		Case $Checkbox1
			$bypass_value = GUICtrlRead($Checkbox1)
			If $bypass_value = 1 Then
				_FileCreate($bypass_creo)
			Else
				FileDelete($bypass_creo)
			EndIf
		Case $Button1
			If $startcmd = "1" Then
;~ 				SplashTextOn("Starting CREO Parametrics")
				Trailfile()
				QA_Map()
				EnvSet("PTC_WF_ROOT", $pathtocache)
				ShellExecute($creoProdPath & "creoprod.bat", "", $start_dir, "open")
;~ 				MsgBox(0x0, "box", "Option 1")
				Exit
			ElseIf $startcmd = "2" Then
;~ 				SplashTextOn("Starting CREO Parametrics Behavior Modeling", "-1", "50", "-1", "-1", 18, "", "", "")
				Sleep(2000)
				Trailfile()
				QA_Map()
				EnvSet("PTC_WF_ROOT", $pathtocache)
				ShellExecute($creoProdPath & "creoengIII.bat", "", $start_dir, "open")
;~ 				MsgBox(0x0, "box", "Option 2")
				Exit
			ElseIf $startcmd = "3" Then
;~ 				SplashTextOn("Starting CREO Parametrics Plastic Advisor", "-1", "50", "-1", "-1", 18, "", "", "")
				Sleep(2000)
				Trailfile()
				QA_Map()
				EnvSet("PTC_WF_ROOT", $pathtocache)
				ShellExecute($creoProdPath & "creoplastic.bat", "", $start_dir, "open")
;~ 				MsgBox(0x0, "box", "Option 3")
				Exit
			ElseIf $startcmd = "4" Then
;~ 				SplashTextOn("Starting CREO Parametrics Manikin", "-1", "50", "-1", "-1", 18, "", "", "")
				Sleep(2000)
				Trailfile()
				QA_Map()
				EnvSet("PTC_WF_ROOT", $pathtocache)
				ShellExecute($creoProdPath & "creomanikin.bat", "", $start_dir, "open")
;~ 				MsgBox(0x0, "box", "Option 4")
				Exit
			ElseIf $startcmd = "5" Then
;~ 				SplashTextOn("Starting CREO Parametrics Advanced Rendering", "-1", "50", "-1", "-1", 18, "", "", "")
				Sleep(2000)
				Trailfile()
				QA_Map()
				EnvSet("PTC_WF_ROOT", $pathtocache)
				ShellExecute($creoProdPath & "creoarx.bat", "", $start_dir, "open")
;~ 				MsgBox(0x0, "box", "Option 5")
				Exit
			ElseIf $startcmd = "6" Then
;~ 				SplashTextOn("Starting CREO Parametrics Design Exploration Extension", "-1", "50", "-1", "-1", 18, "", "", "")
				Sleep(2000)
				Trailfile()
				QA_Map()
				EnvSet("PTC_WF_ROOT", $pathtocache)
				ShellExecute($creoProdPath & "creodex.bat", "", $start_dir, "open")
;~ 				MsgBox(0x0, "box", "Option 6")
				Exit
			ElseIf $startcmd = "8" Then
;~ 				SplashTextOn("Starting CREO Simulate", "-1", "50", "-1", "-1", 18, "", "", "")
				Sleep(2000)
				Trailfile()
				EnvSet("PTC_WF_ROOT", $pathtocache)
				ShellExecute($creoSimProdPath & "simulate.bat", "", $start_dir, "open")
;~ 				MsgBox(0x0, "box", "Option 8")
				Exit
			EndIf
	EndSwitch
WEnd

Func copyFiles($drive)
	;checking for start-in dir

	;-MsgBox(0, "Drive ", $drive)

	Local $config_files = StringSplit($bkp_files, ",") ; Split the string using the delimiter "," and the default flag value.
	;Loop thorugh c drive files first and compare
	For $x = 1 To $config_files[0] ; Loop through the array returned by StringSplit to display the individual values.
		;-MsgBox(0, "", "files: " & $start_dir & "\" & $config_files[$x])
		;Loop through the c:drive first
		Local $aFileList = _FileListToArray($start_dir, $config_files[$x])
		If @error = 1 Then
;~ 			MsgBox(0, "", "Path was invalid.")
		ElseIf @error = 4 Then
;~ 			MsgBox(0, "", "No file(s) were found.")
		Else
			For $y = 1 To $aFileList[0]
				;-MsgBox(0, "File", "Found this file: " & $aFileList[$y])

				;-MsgBox(0, "File", "Find this file now: " & $drive & $bkp_config_dir & "\" & $aFileList[$y])
				If FileExists($drive & $bkp_config_dir & "\" & $aFileList[$y]) Then
					Local $compare = CompareFile($start_dir & "\" & $aFileList[$y], $drive & $bkp_config_dir & "\" & $aFileList[$y], 0)
					;-MsgBox(0, "Compare ", "In Compare: " & $compare)
					If $compare = 1 Then
					;-	MsgBox(0, "Compare ", "copy file 1: ")
						FileCopy($start_dir & "\" & $aFileList[$y], $drive & $bkp_config_dir & "\" & $aFileList[$y], 1)

					ElseIf $compare = -1 Then
					;-	MsgBox(0, "Compare ", "copy file -1: ")
						FileCopy($drive & $bkp_config_dir & "\" & $aFileList[$y], $start_dir & "\" & $aFileList[$y], 1)
					Else

					EndIf
				Else
					;-MsgBox(0, "Compare ", "copy file: ")
					FileCopy($start_dir & "\" & $aFileList[$y], $drive & $bkp_config_dir & "\" & $aFileList[$y], 1)
				EndIf

			Next
		EndIf

		;now loop through the network locations
		Local $aFileList1 = _FileListToArray($drive & $bkp_config_dir & "\", $config_files[$x])
		If @error = 1 Then
;~ 			MsgBox(0, "", "Path was invalid.")
		ElseIf @error = 4 Then
;~ 			MsgBox(0, "", "No file(s) were found.")
		Else
			For $z = 1 To $aFileList1[0]
				;-MsgBox(0, "File", "Found this fileN: " & $aFileList1[$z])

				;-MsgBox(0, "File", "Find this file nowN: " & $start_dir & "\" & $aFileList1[$z])
				If FileExists($start_dir & "\" & $aFileList1[$z]) Then
					Local $compareN = CompareFile($drive & $bkp_config_dir & "\" & $aFileList1[$z], $start_dir & "\" & $aFileList1[$z], 0)
					;-MsgBox(0, "CompareN ", "In CompareN: " & $compareN)
					If $compareN = 1 Then
					;-MsgBox(0, "Compare ", "copy file 1N: ")
						FileCopy($drive & $bkp_config_dir & "\" & $aFileList1[$z], $start_dir & "\" & $aFileList1[$z], 1)

					ElseIf $compareN = -1 Then
					;-MsgBox(0, "Compare ", "copy file -1N: ")
						FileCopy($start_dir & "\" & $aFileList1[$z], $drive & $bkp_config_dir & "\" & $aFileList1[$z], 1)

					Else

					EndIf
				Else
					;-MsgBox(0, "Compare ", "copy fileN: ")
					FileCopy($drive & $bkp_config_dir & "\" & $aFileList1[$z], $start_dir & "\" & $aFileList1[$z], 1)
				EndIf

			Next
		EndIf


	Next

EndFunc   ;==>copyFiles

Func copyfileOnce($drive1)

	;-MsgBox(0, "Drive1 ", $drive1)

	Local $config_filesA = StringSplit($bkp_files, ",") ; Split the string using the delimiter "," and the default flag value.

	For $a = 1 To $config_filesA[0] ; Loop through the array returned by StringSplit to display the individual values.

		Local $aFileListA = _FileListToArray($drive1, $config_filesA[$a])
		If @error = 1 Then
;~ 			MsgBox(0, "", "Path was invalid.")
		ElseIf @error = 4 Then
;~ 			MsgBox(0, "", "No file(s) were found.")
		Else
		For $b = 1 To $aFileListA[0]
				FileCopy($drive1 & $aFileListA[$b], $start_dir & "\" & $aFileListA[$b], 1)

			Next
		EndIf

	Next
	MsgBox(0, "Copied files from your user network drive.", "You may want to double check your https://urldefense.com/v3/__http://config.pro__;!!A16HtNeG!JNEa1k8-GL-Aqfwf6wgwhKLoqKhCLgvDUmIbz1CfjeSbA2J1dR3DYuyRy6tH$  file to make sure it has the correct paths to the auxiliary files.")
	Return("u:\")
EndFunc


Func checkDirs() ;
	;Create the C:data\drive if it doesn't exist.
	Local $newDir = 0;

	If FileExists($start_dir) Then
		$newDir = 0
	Else
		$newDir = DirCreate($start_dir)
	EndIf
	;Create the backup drive if needed.
	Local $homedriveU = StringSplit($homeDrivesU, ",") ; Split the string using the delimiter "," and the default flag value.

	For $i = 1 To $homedriveU[0]
		If StringLeft($pcname, 3) = $homedriveU[$i] Then
			;-MsgBox(0, "File","Found this PC: " & $pcname & " to match string: [" & $homedriveU[$i] & "] " )
			;-Check to make sure the $U drive exsist.
			If FileExists($UDrive) Then
				If FileExists($UDrive & $bkp_config_dir) Then
					;no need to create folder.

				Else
					DirCreate($UDrive & $bkp_config_dir)
					;-if new c data dir created we will grab the files from the users U drive to copy one time if the backup dir doesn't exsist.
					If $newDir = 1 Then
					copyfileOnce("u:\")
					EndIf
				EndIf
			Else
				;Somthing wrong no $U found
				MsgBox(0, "Warning", "The " & $UDrive & " drive not found! No config files will be backed up!")
			EndIf
			;-MsgBox(0, "Exit", "Got out of function at U:")
			Return ("u:\")
		EndIf
	Next

	Local $homedriveI = StringSplit($homeDrivesI, ",") ; Split the string using the delimiter "," and the default flag value.

	For $b = 1 To $homedriveI[0]
		If StringLeft($pcname, 3) = $homedriveI[$b] Then
;~ 			MsgBox(0, "File","Found this PC: " & $pcname & " to match string: [" & $homedriveI[$b] & "] " )
			;-Check to make sure the $I drive exsist.
			If FileExists($IDrive) Then
				If FileExists($I & $bkp_config_dir) Then
					;no need to create folder.
					;-MsgBox(0,"I:\", "There")
				Else
					;-MsgBox(0,"I:\", "Not There")
					DirCreate($IDrive & $bkp_config_dir)
					;-if new c data dir created we will grab the files from the users I drive to copy one time if the backup dir doesn't exsist.
					If $newDir = 1 Then
					copyfileOnce("I:\")
					EndIf
				EndIf
			Else
				;Somthing wrong no $U found
				MsgBox(0, "Warning", "The " & $IDrive & " drive not found! No config files will be backed up!")
			EndIf
			;-MsgBox(0, "Exit", "Got out of function at I:")
			Return ("I:\")
		EndIf
	Next

	;Check to make sure the $JDrive exsist.
	If FileExists($JDrive) Then
		If FileExists($JDrive & $bkp_config_dir) Then
			;no need to create folder.
		Else
			;Creating the backup folder
			DirCreate($JDrive & $bkp_config_dir)
			;-if new c data dir created we will grab the files from the users J or U drive to copy one time if the backup dir doesn't exsist.
			If $newDir = 1 Then
				copyfileOnce("j:\")
			EndIf
		EndIf
		;-MsgBox(0, "Exit", "Got out of function at J:")
		Return ("j:\")
	Else
		;Somthing wrong no $JDrive found
		MsgBox(0, "Warning", "The " & $JDrive & " drive not found! No config files will be backed up!")
		Return ("none")
	EndIf
EndFunc   ;==>checkDirs



Func QA_Map()

	RunWait("C:\PTC\creo4.0M100\QA_Map.bat", "C:\Temp", @SW_MINIMIZE)

EndFunc   ;==>QA_Map

;Trail File Management
Func Trailfile()
	Dim $trail, $i, $filedelete, $J
	$trail = "c:\temp\trail.txt."
	$i = 10

	While $trail & $i < $trail & "50"
		FileDelete($trail & $i)
		$i = $i + 1
	WEnd
	If FileExists($trail & "9") Then
		;MsgBox(0x0, "file exists", $trail & "9 " & "file exists")
		For $i = 2 To 10 Step +1
			$J = $i - 1
			FileMove($trail & $i, $trail & $J, 9)
			;MsgBox(0x0, "file exists", "file exists")
		Next
	EndIf
EndFunc   ;==>Trailfile

Func CompareFile($hSource, $hDestination, $iMethod)
	;Parameters ....:       $hSource -      Full path to the first file
	;                       $hDestination - Full path to the second file
	;                       $iMethod -      0   The date and time the file was modified
	;                                       1   The date and time the file was created
	;                                       2   The date and time the file was accessed
	;Return values .:                       -1  The Source file time is earlier than the Destination file time
	;                                       0   The Source file time is equal to the Destination file time
	;                                       1   The Source file time is later than the Destination file time
	;MsgBox(0x0,"hSource",$hSource);
	$aSource = FileGetTime($hSource, $iMethod, 0)
	;MsgBox(0x0,"Asource",$aSource);
	$aDestination = FileGetTime($hDestination, $iMethod, 0)
	;MsgBox(0x0,"aDestination",$aDestination);

	For $a = 0 To 5
		If $aSource[$a] <> $aDestination[$a] Then
			If $aSource[$a] < $aDestination[$a] Then
				Return -1
			Else
				Return 1
			EndIf
		EndIf
	Next
	Return 0
EndFunc   ;==>CompareFile

Func callHome()

	Local $pcPreFix = StringSplit($notBossPcs, ",") ; Split the string using the delimiter "," and the default flag value.
	For $i = 1 To $pcPreFix[0]
		;-Check to make see if PC falls in the list of non-Boss PCs.
;~ 			MsgBox(0, "File","Found this PC: " & $pcname & " string =: [" & $pcPreFix[$i] & "] " )
		If StringLeft($pcname, 3) = $pcPreFix[$i] Then
			If $pcPreFix[$i] == "LYN"  Then
				;-MsgBox(0,$pcPreFix[$i], "PcName = " & $pcname)
				If FileExists($localUpdateCheckFile) and FileExists($LYNupdateCheckLoc) Then
					;-MsgBox(0,"File is there","File is there")
					Local $compareN = CompareFile($localUpdateCheckFile, $LYNupdateCheckLoc, 0)
;~ 					MsgBox(0, "CompareN ", "In CompareN: " & $compareN)
						If $compareN = 1 Then
						;-MsgBox(0, "Compare ", "copy file 1N: ")
							FileCopy($LYNupdateCheckLoc ,$localUpdateCheckFile,1)
							Return
						ElseIf $compareN = -1 Then
						;-MsgBox(0, "Compare ", "copy file -1N: ")
							FileCopy($LYNupdateCheckLoc ,$localUpdateCheckFile,1)
							Return
						Else
							Return
					EndIf

				Else
						If FileExists($LYNupdateCheckLoc) Then
						;-Copy fiile to local machine
						;-MsgBox(0,"File is not there","testing")
						FileCopy($LYNupdateCheckLoc ,$localUpdateCheckFile,1)
						Return
						Else
						;-exit gracefully
						Return
						EndIf
				EndIf
			ElseIf $pcPreFix[$i] == "BEA"  Then
				;-MsgBox(0,$pcPreFix[$i], "PcName = " & $pcname)
				If FileExists($localUpdateCheckFile) and FileExists($BEAupdateCheckLoc) Then
					;-MsgBox(0,"File is there","File is there")
					Local $compareN = CompareFile($localUpdateCheckFile, $BEAupdateCheckLoc, 0)
;~ 					MsgBox(0, "CompareN ", "In CompareN: " & $compareN)
						If $compareN = 1 Then
						;-MsgBox(0, "Compare ", "copy file 1N: ")
							FileCopy($BEAupdateCheckLoc ,$localUpdateCheckFile,1)
							Return
						ElseIf $compareN = -1 Then
						;-MsgBox(0, "Compare ", "copy file -1N: ")
							FileCopy($BEAupdateCheckLoc ,$localUpdateCheckFile,1)
							Return
						Else
							Return
					EndIf

				Else
						If FileExists($BEAupdateCheckLoc) Then
						;-Copy fiile to local machine
						;-MsgBox(0,"File is not there","testing")
						FileCopy($BEAupdateCheckLoc ,$localUpdateCheckFile,1)
						Return
						Else
						;-exit gracefully
						Return
						EndIf
				EndIf
				ElseIf $pcPreFix[$i] == "SPB"  Then
				;-MsgBox(0,$pcPreFix[$i], "PcName = " & $pcname)
				If FileExists($localUpdateCheckFile) and FileExists($SPBupdateCheckLoc) Then
					;-MsgBox(0,"File is there","File is there")
					Local $compareN = CompareFile($localUpdateCheckFile, $SPBupdateCheckLoc, 0)
;~ 					MsgBox(0, "CompareN ", "In CompareN: " & $compareN)
						If $compareN = 1 Then
						;-MsgBox(0, "Compare ", "copy file 1N: ")
							FileCopy($SPBupdateCheckLoc ,$localUpdateCheckFile,1)
							Return
						ElseIf $compareN = -1 Then
						;-MsgBox(0, "Compare ", "copy file -1N: ")
							FileCopy($SPBupdateCheckLoc ,$localUpdateCheckFile,1)
							Return
						Else
							Return
					EndIf

				Else
						If FileExists($SPBupdateCheckLoc) Then
						;-Copy fiile to local machine
						;-MsgBox(0,"File is not there","testing")
						FileCopy($SPBupdateCheckLoc ,$localUpdateCheckFile,1)
						Return
						Else
						;-exit gracefully
						Return
						EndIf
				EndIf
				ElseIf $pcPreFix[$i] == "IRO"  Then
				;-MsgBox(0,$pcPreFix[$i], "PcName = " & $pcname)
				If FileExists($localUpdateCheckFile) and FileExists($IROupdateCheckLoc) Then
					;-MsgBox(0,"File is there","File is there")
					Local $compareN = CompareFile($localUpdateCheckFile, $IROupdateCheckLoc, 0)
;~ 					MsgBox(0, "CompareN ", "In CompareN: " & $compareN)
						If $compareN = 1 Then
						;-MsgBox(0, "Compare ", "copy file 1N: ")
							FileCopy($IROupdateCheckLoc ,$localUpdateCheckFile,1)
							Return
						ElseIf $compareN = -1 Then
						;-MsgBox(0, "Compare ", "copy file -1N: ")
							FileCopy($IROupdateCheckLoc ,$localUpdateCheckFile,1)
							Return
						Else
							Return
					EndIf

				Else
						If FileExists($IROupdateCheckLoc) Then
						;-Copy fiile to local machine
						;-MsgBox(0,"File is not there","testing")
						FileCopy($IROupdateCheckLoc ,$localUpdateCheckFile,1)
						Return
						Else
						;-exit gracefully
						Return
						EndIf
				EndIf
				ElseIf $pcPreFix[$i] == "ELC"  Then
				;-MsgBox(0,$pcPreFix[$i], "PcName = " & $pcname)
				If FileExists($localUpdateCheckFile) and FileExists($ELCupdateCheckLoc) Then
					;-MsgBox(0,"File is there","File is there")
					Local $compareN = CompareFile($localUpdateCheckFile, $ELCupdateCheckLoc, 0)
;~ 					MsgBox(0, "CompareN ", "In CompareN: " & $compareN)
						If $compareN = 1 Then
						;-MsgBox(0, "Compare ", "copy file 1N: ")
							FileCopy($ELCupdateCheckLoc ,$localUpdateCheckFile,1)
							Return
						ElseIf $compareN = -1 Then
						;-MsgBox(0, "Compare ", "copy file -1N: ")
							FileCopy($ELCupdateCheckLoc ,$localUpdateCheckFile,1)
							Return
						Else
							Return
					EndIf

				Else
						If FileExists($ELCupdateCheckLoc) Then
						;-Copy fiile to local machine
						;-MsgBox(0,"File is not there","testing")
						FileCopy($ELCupdateCheckLoc ,$localUpdateCheckFile,1)
						Return
						Else
						;-exit gracefully
						Return
						EndIf
				EndIf
				ElseIf $pcPreFix[$i] == "RIV"  Then
				;-MsgBox(0,$pcPreFix[$i], "PcName = " & $pcname)
				If FileExists($localUpdateCheckFile) and FileExists($RIVupdateCheckLoc) Then
					;-MsgBox(0,"File is there","File is there")
					Local $compareN = CompareFile($localUpdateCheckFile, $RIVupdateCheckLoc, 0)
;~ 					MsgBox(0, "CompareN ", "In CompareN: " & $compareN)
						If $compareN = 1 Then
						;-MsgBox(0, "Compare ", "copy file 1N: ")
							FileCopy($RIVupdateCheckLoc ,$localUpdateCheckFile,1)
							Return
						ElseIf $compareN = -1 Then
						;-MsgBox(0, "Compare ", "copy file -1N: ")
							FileCopy($RIVupdateCheckLoc ,$localUpdateCheckFile,1)
							Return
						Else
							Return
					EndIf

				Else
						If FileExists($RIVupdateCheckLoc) Then
						;-Copy fiile to local machine
						;-MsgBox(0,"File is not there","testing")
						FileCopy($RIVupdateCheckLoc ,$localUpdateCheckFile,1)
						Return
						Else
						;-exit gracefully
						Return
						EndIf
				EndIf
			Else
				Return ;-On list but not doing anything.
			EndIf

		Else

;~ 			MsgBox(0,"next","next")


		EndIf
	Next
			;-Only get here if PC name isn't on the $notBossPcs list
			If FileExists($localUpdateCheckFile) Then
					;-MsgBox(0,"File is there","File is there")
					Local $compareN = CompareFile($localUpdateCheckFile, $IROupdateCheckLoc, 0)
;~ 					MsgBox(0, "CompareNout ", "In CompareNout: " & $compareN)
						If $compareN = 1 Then
						;-MsgBox(0, "Compare ", "copy file 1N: ")
							FileCopy($IROupdateCheckLoc ,$localUpdateCheckFile,1)
							Return
						ElseIf $compareN = -1 Then
						;-MsgBox(0, "Compare ", "copy file -1N: ")
							FileCopy($IROupdateCheckLoc ,$localUpdateCheckFile,1)
							Return
						Else
							Return
					EndIf

				Else
						FileCopy($IROupdateCheckLoc ,$localUpdateCheckFile,1)
;~ 						MsgBox(0,"File is not there","testing")
						Return
				EndIf



EndFunc


Func updatefile()

	If FileExists($localUpdateCheckFile) Then
;~ 		MsgBox(0,"Found","Found " & $localUpdateCheckFile)

	Local $file = $localUpdateCheckFile

	FileOpen($file, 0)

	Dim $line1 = FileReadLine($file, 1)

;~ 	MsgBox (0,"line", "File " & $line1)

	If $line1 ="yes" Then

	For $i = 2 to _FileCountLines($file)
		$line = FileReadLine($file, $i)
		Local $lines= StringSplit($line, ",")
;~ 		msgbox(0,'','the line ' & $i & ' is ' & $lines[1] & $lines[2])
		FileCopy($lines[1],$lines[2],$FC_OVERWRITE + $FC_CREATEPATH)
	Next
	FileClose($file)

	Else
;~ 			MsgBox(0,"No","out")
			FileClose($file)
			Return
		EndIf


	EndIf


EndFunc
