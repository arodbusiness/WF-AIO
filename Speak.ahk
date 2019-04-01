#NoEnv
#SingleInstance, Force
#NoTrayIcon

oVoice := ComObjCreate("SAPI.SpVoice")
FileRead, TextFile, Text2Speak.txt
Rewards := StrSplit(TextFile, ",")
Loop % Rewards.MaxIndex(){
	oVoice.Speak(Rewards[A_Index] . " is available")	
	Sleep 400
}

ExitApp