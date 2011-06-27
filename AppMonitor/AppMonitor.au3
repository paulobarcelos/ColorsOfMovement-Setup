; The path to the settings file
$settingsPath = @ScriptDir & "\" & "AppMonitor Settings.txt"
; Try to open the settings file
$settings = FileOpen($settingsPath)
If $settings = -1 Then
    MsgBox(0, "Error", "Settings file not found. Make sure that 'AppMonitor Settings.txt' exists in the same folder as the AppMonitor.exe")
    Exit
EndIf
; Get the app filename
$app = FileReadLine($settings, 1)
If @error = -1 Then 
	MsgBox(0, "Error", "The app path was not specified in the line 1 of the settings file.")
    Exit
EndIf
If $app = "" Then 
	MsgBox(0, "Error", "The app path was not specified in the line 1 of the settings file.")
    Exit
EndIf
; Get the app timestamp filename
$appTimestamp = FileReadLine($settings, 2)
If @error = -1 Then 
	MsgBox(0, "Error", "The app timestamp path was not specified in the line 2 of the settings file.")
    Exit
EndIf
If $app = "" Then 
	MsgBox(0, "Error", "The app timestamp path was not specified in the line 2 of the settings file.")
    Exit
EndIf
; Get the startup delay
$startUpDelay = FileReadLine($settings, 3)
If @error = -1 Then 
	MsgBox(0, "Error", "The app's startup delay was not specified in the line 3 of the settings file.")
    Exit
EndIf
If $app = "" Then 
	MsgBox(0, "Error", "The app's startup delay was not specified in the line 3 of the settings file.")
    Exit
EndIf
; Close the settings
FileClose($settings)

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

	; Wait the app to get active
	WinWaitActive($app)
	; Wait a couple of seconds more to make sure everything was initialized fine
	Sleep($startUpDelay)

	; Now we keep monitoring the timestamp, if we notice the timestamp is not being updated, kill the app and start over
	$lastTimstamp = -1
	$curTimstamp = 0
	While $curTimstamp > $lastTimstamp	
		$timestampFile = FileOpen($appTimestamp)
		$lastTimstamp = $curTimstamp
		$curTimstamp = FileReadLine($settings)
		FileClose($timestampFile)
		Sleep(1000)
	WEnd

	WinKill($app)
	WinWaitClose($app)
	; increment the number of fails
	$fails = $fails + 1
WEnd
; Too many fails, time to reboot!
Shutdown(6)