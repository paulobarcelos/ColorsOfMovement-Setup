; The path to the settings file
$settingsPath = @ScriptDir & "\" & "AppMonitor Settings.txt"
; Try to open the settings file
$settings = FileOpen($settingsPath)
If $settings = -1 Then
    MsgBox(0, "Error", "Settings file not found. Make sure that 'AppMonitor Settings.txt' exists in the same folder as the AppMonitor.exe")
    Exit
EndIf
; Get the working rirectory
$dir = FileReadLine($settings, 1)
If @error = -1 Then 
	MsgBox(0, "Error", "The working directory path was not specified in the line 1 of the settings file.")
    Exit
EndIf
If $dir = "" Then 
	MsgBox(0, "Error", "The working directory path was not specified in the line 1 of the settings file.")
    Exit
EndIf
; Get the app filename
$app = FileReadLine($settings, 2)
If @error = -1 Then 
	MsgBox(0, "Error", "The app path was not specified in the line 2 of the settings file.")
    Exit
EndIf
If $app = "" Then 
	MsgBox(0, "Error", "The app path was not specified in the line 2 of the settings file.")
    Exit
EndIf
; Get the app window name
$appWindowName = FileReadLine($settings, 3)
If @error = -1 Then 
	MsgBox(0, "Error", "The app window name was not specified in the line 3 of the settings file.")
    Exit
EndIf
If $appWindowName = "" Then 
	MsgBox(0, "Error", "The app window name was not specified in the line 3 of the settings file.")
    Exit
EndIf
; Get the app window class
$appWindowClass = FileReadLine($settings, 4)
If @error = -1 Then 
	MsgBox(0, "Error", "The app window class was not specified in the line 4 of the settings file.")
    Exit
EndIf
If $appWindowClass = "" Then 
	MsgBox(0, "Error", "The app window class was not specified in the line 4 of the settings file.")
    Exit
EndIf
; Get the app timestamp filename
$appTimestamp = FileReadLine($settings, 5)
If @error = -1 Then 
	MsgBox(0, "Error", "The app timestamp path was not specified in the line 5 of the settings file.")
    Exit
EndIf
If $app = "" Then 
	MsgBox(0, "Error", "The app timestamp path was not specified in the line 5 of the settings file.")
    Exit
EndIf
; Get the startup delay
$startUpDelay = FileReadLine($settings, 6)
If @error = -1 Then 
	MsgBox(0, "Error", "The app's startup delay was not specified in the line 6 of the settings file.")
    Exit
EndIf
If $app = "" Then 
	MsgBox(0, "Error", "The app's startup delay was not specified in the line 6 of the settings file.")
    Exit
EndIf
; Close the settings
FileClose($settings)

; Change the working directory
FileChangeDir($dir)

; keep track of the whole number of fails
$fails = 0
$maxFails = 3
While $fails < $maxFails
	; Run the app!
	$runSuccess = Run($app)
	$runTryCount = 0
	$runTryMax = 5
	; Keep trying to open it until we reach the max number of tries. 
	While $runSuccess = 0
		; If we try more than the max number... time to restart!
		If $runTryCount > $runTryMax Then
			; Too many tries, time to reboot!
			Shutdown(6)
			Exit
		EndIf
		$runSuccess = Run($app)
		$runTryCount = $runTryCount + 1
		Sleep(2000)
	WEnd
	
	; Wait a couple of seconds more to make sure everything was initialized fine
	Sleep($startUpDelay)

	; Now we keep monitoring the timestamp, if we notice the timestamp is not being updated, kill the app and start over
	$lastTimstamp = -1
	$curTimstamp = 0
	$successTimestamps = 0
	While $curTimstamp > $lastTimstamp	
		$timestampFile = FileOpen($appTimestamp)
		$lastTimstamp = $curTimstamp
		$curTimstamp = FileReadLine($settings)
		FileClose($timestampFile)
		; Increase the count of successfull checks on the timestamp
		$successTimestamps = $successTimestamps + 1
		; If we the timestamp was successfull for more than 35 times (around 1 minute) we consider it stable and zero the number of fails
		If $successTimestamps > 35 Then 
			$fails = 0
		Exit
EndIf
		Sleep(1500)
	WEnd

	; Ok, time to kill the app
	WinKill("[TITLE:" & $appWindowName & "; CLASS:" & $appWindowClass & ";]")
	WinWaitClose("[TITLE:" & $appWindowName & "; CLASS:" & $appWindowClass & ";]", "", 6)
	
	; Wait a little bit to make sure everything closed properly
	Sleep(1500)
	
	; increment the number of fails
	$fails = $fails + 1
WEnd
; Too many fails, time to reboot!
Shutdown(6)