#Persistent
#NoEnv
#SingleInstance, Force
#HotkeyInterval 1000
#MaxHotkeysPerInterval 1000000
#Include Gdip_All.ahk
#Include Gdip_wf.ahk

;SetFormat, float, 03
CoordMode, Pixel, Window
CoordMode, Mouse, Window
SetMouseDelay, -1
SetKeyDelay, -1
If !pToken := Gdip_Startup(){
	MsgBox, No Gdiplus 
	ExitApp
}
CheckFiles()

global FileSettings := A_ScriptDir . "\WF-AIO.ini"

IniRead, WindowX, %FileSettings%, Main, X
IniRead, WindowY, %FileSettings%, Main, Y
IniRead, WindowW, %FileSettings%, Main, W
IniRead, WindowH, %FileSettings%, Main, H
IniRead, FollowingChat, %FileSettings%, Main, FollowingChat
IniRead, UseVoice, %FileSettings%, Main, Speech


hCurs:=DllCall("LoadCursor","UInt",NULL,"Int",32649,"UInt") ;IDC_HAND
OnMessage(0x200,"WM_MOUSEMOVE")
OnMessage(0x202,"WM_LBUTTONUP")
OnMessage(0x201, "WM_LBUTTONDOWN")
;======================SET PREDETERMINED VARIABLES====================
UnwantedItems := "Alloy Plate, Argon Crystal, Control Module, Credits, Circuits, Endo, Detonite Injector, Ferrite, Fieldron, Gallium, Morphics, Mutagen Mass, Mutalist Alad V Nav Coordinate,Nano Spores, Neurodes, Neural Sensors, Plastids, Polymer Bundle, Rubedo, Salvage, Synthula, Void Traces"
global CurrentTab := "Alerts", CurrentRiven := "kohm"
WindowInc := 50
AFKswing2 :=0, AFKw := 0, wDown := 0
;======================MAKE TRAY MENU==============================
Menu, Tray, Icon, %A_ScriptDir%\wf.ico
Menu, Tray, Click, 1
Menu, Tray, NoStandard
Menu, Tray, Add, Text to Speech, ToggleTTS
Menu, Tray, Default, Text to Speech
Menu, Tray, Add
Menu, HotkeyTreeMButton, Add, Toggle MButton, ToggleMButton
Menu, HotkeyTreeMButton, Add
Menu, HotkeyTreeMButton, Add, Spam E, ChooseSpamE
Menu, HotkeyTreeMButton, Add, Spam LMB, ChooseSpamLMB
Menu, HotkeyTreeE, Add, Hold E to Spam, ToggleESpam
Menu, HotkeyTree, Add, Mbutton, :HotkeyTreeMButton
Menu, HotkeyTree, Add, E, :HotkeyTreeE
Menu, Tray, Add, Hotkeys, :HotkeyTree
Menu, Tray, Add, Set Custom Hotkey, ShowCustomHotkeyGUI
Menu, Tray, Add
Menu, Tray, Add, Restart, RestartFn
Menu, Tray, Add, Close, CloseFn
Menu, Tray, Tip, Warframe Script
;=================GET IMAGE/FONT DIMENSIONS===========================
FileName := A_ScriptDir . "\html.css"
if (FileExist(FileName)){
	FileRead, HTML, %FileName%
	FoundPos := RegexMatch(HTML, "i)img\.reward"), Match:=""
	FoundPos := RegExMatch(HTML, "O)width:[ ]{0,10}(\d{1,3})[ ]{0,10}px", Match, FoundPos)
	global RewardImgW := Match[1]
	;;==============================================================
	FoundPos := RegexMatch(HTML, "i)img\.RelicReward"), Match:=""
	FoundPos := RegExMatch(HTML, "O)height:[ ]{0,10}(\d{1,3})[ ]{0,10}px)", Match, FoundPos)
	global RelicRewardImgH := Match[1]
	;;==============================================================
	FoundPos := RegexMatch(HTML, "i)img\.icon"), Match:=""
	FoundPos := RegExMatch(HTML, "O)height:[ ]{0,10}(\d{1,3})[ ]{0,10}px", Match, FoundPos)
	FontHeight := Match[1]
	;;==============================================================
	FoundPos := RegExMatch(HTML, "O)background-color:[ ]{0,10}#([0-9A-F]{6});", Match)
	BGcolor := Match[1]
	;;==============================================================
	HTML := ""
}else{
	global RewardImgW := 128, RelicRewardImgH := 28
	FontHeight := 16
	BGcolor := 0E0C13
}
global RewardImgW := RewardImgW="" ? 128 : RewardImgW
global RelicRewardImgH := RelicRewardImgH="" ? 28 : RelicRewardImgH
FontHeight := FontHeight="" ? 16 : FontHeight
;=================SET CRED/PLAT IMAGES====================
CredIMG := AssignImgHTML(A_ScriptDir . "\Images\Rewards\Credits.png", "https://vignette.wikia.nocookie.net/warframe/images/0/01/CreditsLarge.png", 0, FontHeight)
PlatIMG := AssignImgHTML(A_ScriptDir . "\Images\Rewards\Plat.png", "https://vignette.wikia.nocookie.net/warframe/images/e/e7/PlatinumLarge.png", 0, FontHeight)
DucatIMG := AssignImgHTML(A_ScriptDir . "\Images\Rewards\Ducat.png", "https://vignette.wikia.nocookie.net/warframe/images/9/97/PrimeBucks.png", 0, FontHeight)
;==============CHOOSE COLOR FOR ENTIRE UI==================
MinC := 12.0, MaxC := 140.0, HighC := MaxC*0.5
global Color := ChooseRandomColor(MinC, MaxC, HighC)
;================PUT NEW COLORS INTO CSS/JS FILES ============
FileRead, HTML, javascript.js
JSvars := "var unHighlighted = ""#" . Color[1] . """;`r`nvar Highlighted = ""#" . Color[2] . """;`r`n`r`n"
HTML := JSvars . SubStr(HTML, InStr(HTML, "open"))
file := FileOpen("javascript2.js", "w"), file.Write(HTML), file.Close(), HTML := ""
FileRead, HTML, html.css
HTML := RegexReplace(HTML, "border-color[ ]{0,5}:[ ]{0,5}#(.+?)[ ]{0,5};", "border-color:#" . Color[1] . ";")
HTML := RegexReplace(HTML, "width[ ]{0,5}:[ ]{0,5}(.+?)[ ]{0,5};", "width: " . RewardImgW . "px;", 0, 1, InStr(HTML, "table#Alert tr:nth-child(1) td"))
file := FileOpen("html2.css", "w"), file.Write(HTML), file.Close(), HTML := ""
;================SET GUI VARIABLES========================
WindowHmin:=350, WindowHmax:=880
ButtonW := 22
MinButtonX := WindowW-ButtonW+2, MinButtonY := 0 
ButtonX := 0
ButtonX2 := WindowW-ButtonW, ButtonX3 := ButtonX2-ButtonW-1
ButtonY1 := 0, ButtonY2 := ButtonY1+ButtonW+1, ButtonY3 := ButtonY2+ButtonW+1
CetusX := WindowW*0.55, CetusY := 4
CetusW := 20, CetusTextWidth := 110
CetusX2 := CetusX+CetusW, CetusY2 := CetusY+2
SunIcon := MakeSun(CetusW)
MoonIcon := MakeMoon(CetusW)
ActiveXY := ButtonW*3+3
SplashX := ButtonW, SplashY := 0
SplashW := WindowW-ButtonW*2, SplashClickW := 0
SplashH := ButtonW*3
;====================BUILD GUI COMPONENTS===============
Gui, -Caption +AlwaysOnTop +HwndMyGuiWindow
Gui, Color, %BGcolor%, %BGcolor%
Gui, Font, CFFFFFF w700
Gui Font, s11, Helvetica bold
Gui, Add, Text, x2 y153 vRelicText, Relic(s):
Gui, Add, Edit, x62 w240 y150 vRelicIn, Lith B3
Gui, Add, Button, x302 y148 gLookupRelics vLookupButton, Go
;=============================================
Gui, Add, Text, x10 y153 vItemsText, Item(s):
Gui, Add, Edit, x70 w260 y150 vRewardItems, Meso R1, Neo H2, Lith O1, Lith B5
Gui, Add, Text, x10 y177 vTypeText, Type(s):
Gui, Add, Edit, x70 w260 y174 vMissionTypes, Capture,Rescue,Survival
Gui, Add, Text, x10 y203 vShowText, Show:
Gui, Add, Radio, x60 y204 vAllResults, All 
Gui, Add, Radio, x104 y204 vShortResults Checked, Items 
Gui, Add, Button, x265 y197 gLookupMissions vMissionButton, Search
;=============================================
Gui, Add, Text, x35 y118 vRivenText, Enter Riven:
Gui, Add, Edit, x123 y115 w100 vRivenInput, kohm
Gui, Add, Button, x230 y113 gSearchRiven vRivenButton, Enter
Gui, Add, Text, x25 y118 vPriceText, Item:
Gui, Add, Edit, x65 w190 y115 vItemName, Serration
Gui, Add, Button, x265 y113 gLookupPrice vPriceButton, Search
;=============================================
Gui, Add, Picture, x%ButtonX2% y%ButtonY1% w%ButtonW% h%ButtonW% vMinimizer gMinFn BackgroundTrans 0xE,
Gui, Add, Picture, x%ButtonX2% y%ButtonY2% w%ButtonW% h%ButtonW% varrowUp gUpArrowFn BackgroundTrans 0xE,
Gui, Add, Picture, x%ButtonX2% y%ButtonY3% w%ButtonW% h%ButtonW% varrowDown gDownArrowFn BackgroundTrans 0xE,
Gui, Add, Picture, x%ButtonX3% y%ButtonY1% w%ButtonW% h%ButtonW% vSettings gSettingsFn BackgroundTrans 0xE,

Gui, Add, Picture, x%ButtonX% y%ButtonY1% w%ButtonW% h%ButtonW% vChatButton gChatButtonFn BackgroundTrans 0xE,
Gui, Add, Picture, x%ButtonX% y%ButtonY2% w%ButtonW% h%ButtonW% vMoveButton gMoveButtonFn BackgroundTrans 0xE,
Gui, Add, Picture, x%ButtonX% y%ButtonY3% w%ButtonW% h%ButtonW% vEButton gToggleESpam BackgroundTrans 0xE,
Gui, Add, Picture, x%CetusX% y%CetusY% w%CetusW% h%CetusW% vCetusIcon BackgroundTrans 0xE,
Gui, Add, Text, x%CetusX2% y%CetusY2% w%CetusTextWidth% h%CetusW% vCetusText BackgroundTrans,
Gui, Add, Picture, x%SplashX% y%SplashY% w%SplashW% h%SplashH% vSplash BackgroundTrans 0xE,
Gui, Add, Picture, x%SplashX% y%SplashY% w%SplashClickW% h%SplashH% vSplashClick gSplashFn BackgroundTrans 0xE,
SplashClickW := MakeSplash(Splash, Color[3], A_ScriptDir . "\Images\Warframe_Logo.png")
GuiControl, Move, SplashClick, x%SplashX% y%SplashY% w%SplashClickW% h%SplashH%

MakeMinimize(Minimizer,Color[4]), MakeMove(MoveButton,Color[4],2)
MakeArrow(arrowDown,Color[4],2), MakeArrow(arrowUp,Color[4],0)
;MakeCog(Settings,Color[4])
HoldESpam := 0

if (FollowingChat=1){
	MakeChat(ChatButton,Color[4],4)
	SetTimer, MoveWindow, 500
}else
	MakeChat(ChatButton,Color[4],2)

GoSub, ToggleESpam
Gui, Add, ActiveX, vHTMLDisplay, Chrome.Browser ;Chrome.Browser Shell.Explorer
ComObjConnect(HTMLDisplay, WB_events), HTMLDisplay.silent := true
GoSub, HideAllControls
;=================BUILD HTML VARIABLES======================
HTMLhead := "<!DOCTYPE html>`r`n<html>`r`n<head>`r`n<meta http-equiv=""X-UA-Compatible"" content=""IE=edge"">`r`n<meta charset=""utf-8"">`r`n<link rel=""stylesheet"" href=""" . A_ScriptDir . "\html2.css"">`r`n</head>`r`n`r`n<body>`r`n"
HTMLtail := "`r`n<script src=""" . A_ScriptDir . "\javascript2.js""></script>`r`n</body>`r`n</html>"
HTMLalerts := "<div id=""AlertTabs"" class=""Buttons"">`r`n`t
	<button class=""tablinks3"" id=""AlertsAlertsButton"" onclick=""openAlertTab('Alerts')"">Alerts</button>`r`n`t
	<button class=""tablinks3"" id=""FissuresButton"" onclick=""openAlertTab('Fissures')"">Fissures</button>`r`n`t
	<button class=""tablinks3"" id=""InvasionsButton"" onclick=""openAlertTab('Invasions')"">Invasions</button>`r`n
	</div>`r`n<div id=""Alerts"" class=""maintabcontent"">`r`n`tAlerts are found here.`t`n`t<p id=""countdown""></p>`r`n</div>`r`n`r`n"
HTMLrelics := "<div id=""RelicTabs"" class=""Buttons"">`r`n`t
	<button class=""tablinks2"" id=""RewardsButton"" onclick=""openRelicTab('Rewards')"">Relics</button>`r`n`t
	<button class=""tablinks2"" id=""MissionsButton"" onclick=""openRelicTab('Missions')"">Missions</button>`r`n`t
	</div>`r`n`r`n<div id=""Rewards"" class=""maintabcontent"">`r`n`tEnter Relics above or press Ctrl+Shift+L while in game to capture players' Relics.`r`n</div>`r`n<div id=""Missions"" class=""maintabcontent"">`r`n`tEnter Items to find from Missions.`r`n</div>`r`n`r`n"
HTMLprices := "<div id=""Prices"" class=""maintabcontent"">`r`n`tEnter an Item above to get buyers and sellers from https://warframe.market/.`r`n</div>`r`n`r`n"
HTMLrivens := "<div id=""Rivens"" class=""maintabcontent"">`r`n`tEnter a Riven above to see recent sales from https://semlar.com/rivenprices/.`r`n</div>`r`n`r`n"
HTMLselector := "`r`n<div id=""MainTabButtons"">`r`n`t
	<button class=""maintabbutton"" onclick=""openTabMain('Alerts')"" id=""AlertsButton"">Alerts</button>`r`n`t
	<button class=""maintabbutton"" onclick=""openTabMain('Relics')"" id=""RelicsButton"">Rewards</button>`r`n`t
	<button class=""maintabbutton"" onclick=""openTabMain('Rivens')"" id=""RivensButton"">Rivens</button>`r`n`t
	<button class=""maintabbutton"" onclick=""openTabMain('Prices','Buyers')"" id=""PricesButton"">Prices</button>`r`n</div>`r`n`r`n"
HTMLimgPOP := "`r`n`r`n<div id=""HugeIMG"">`r`n<img id=""HugeIMGactual"">`r`n</div>`r`n"
HTML := HTMLhead . HTMLselector . HTMLimgPOP . HTMLalerts . HTMLrelics . HTMLrivens . HTMLprices . HTMLtail
Display(HTMLDisplay,HTML)
While (HTMLDisplay.Busy || HTMLDisplay.ReadyState<3)
	Sleep 100
;=====================================================
MButtonEnabled := 0, SpamButton := "E"
CustomHotkeyON := 0, SetHotkey := "F1", SetOutputKey := "4", SetHotkeyTime := 25.0
HotkeyTimeMS := floor(SetHotkeyTime*1000)
Hotkey, %SetHotkey%, CustomButton
SoundPlay, %A_WinDir%\Media\Speech On.wav
oVoice := ComObjCreate("SAPI.SpVoice")
GoSub, UpdateTrayMenu	
Gui Show, w0 h0, Warframe AIO
GoSub, MoveWindow
GoSub, UpdateAPI
SetTimer, UpdateAPI, 120000				;;;;Update every (ms) - 2 min
HTMLDisplay.document.parentWindow.openTabMain("Alerts","AlertsAlerts")
GoSub, ResizeWindow
GoSub, SpeakAlerts
SetTimer, SpeakAlerts, 600000		 	;;;;Speak every (ms) - 10 min
Loop {
	if (!WinActive("ahk_exe Warframe.x64.exe")){
		if (wDown=1){
			Send {w up}
			wDown=0
		}
		AFKw := AFKswing2 := 0
		SetTimer, SpamE, Off
		SetTimer, SpamLMB, Off
		SetTimer, CustomSpam, Off
	}
	Sleep 50
}

~e::
	if (WinActive("ahk_exe warframe.x64.exe") && HoldESpam=1){
		Keywait, e, t0.33 ;<- see if key is being held down for 3/4 of a second
		err := Errorlevel
		if (err){                 ;<- if key was held for that long 
			SetTimer, SpamE, 25
			HoldingE=1
			return
		}
	}
return

~e Up::
	SetTimer, SpamE, Off
	HoldingE=1
return

SpamE:
	Send {e}
return

SpamLMB:
	Send {LButton}
return


~RButton::
	if WinActive("ahk_exe warframe.x64.exe")
	{
		SetTimer, SpamE, Off
		SetTimer, SpamLMB, Off
	}
return

~MButton::
	if (WinActive("ahk_exe warframe.x64.exe") && MButtonEnabled=1){
		if (AFKswing2=0){
			AFKswing2=1
			SetTimer, Spam%SpamButton%, 25
		}else{
			AFKswing2=0
			SetTimer, SpamE, Off
			SetTimer, SpamLMB, Off
		}
	}
return

~w Up::
	if (AFKw=1){
		AFKw=0
	}
return

~XButton2::
	if WinActive("ahk_exe warframe.x64.exe"){
		if (AFKw=0){
			AFKw=1
			Send {w down}
		}else{
			AFKw=0
			Send {w up}
		}
	}
return

~XButton1::
	if WinActive("ahk_exe warframe.x64.exe"){
		Send {c}
		Send {e}
	}
return

MinFn:
	GoSub, MinimizeWindow
return

CloseFn:
	ExitApp
return

RestartFn:
	Reload
return

MinimizeWindow:
	LastPosX := "null"
	WinMinimize, Warframe AIO
return

ToggleTTS:
	if (UseVoice=1)
		UseVoice=0
	else
		UseVoice=1
	IniWrite, %UseVoice%, %FileSettings%, Main, Speech
	GoSub, UpdateTrayMenu
return

ToggleMButton:
	if (MButtonEnabled=1)
		MButtonEnabled := 0
	else
		MButtonEnabled := 1
	GoSub, UpdateTrayMenu
return

ChooseSpamE:
	SpamButton := "E"
	GoSub, UpdateTrayMenu
return

ChooseSpamLMB:
	SpamButton := "LMB"
	GoSub, UpdateTrayMenu
return

ToggleESpam:
	if (HoldESpam=1){
		HoldESpam := 0
		MakeE(EButton,Color[4],2)
	}else{
		HoldESpam := 1
		MakeE(EButton,Color[4],4)
	}
	GoSub, UpdateTrayMenu
return

UpdateTrayMenu:
	if (UseVoice=1)
		Menu, Tray, Check, Text to Speech
	else
		Menu, Tray, Uncheck, Text to Speech
	
	if (MButtonEnabled = 1)
		Menu, HotkeyTreeMButton, Check, Toggle MButton
	else
		Menu, HotkeyTreeMButton, Uncheck, Toggle MButton
	
	if (SpamButton = "E"){
		Menu, HotkeyTreeMButton, Check, Spam E
		Menu, HotkeyTreeMButton, Uncheck, Spam LMB
	}else{
		Menu, HotkeyTreeMButton, Check, Spam LMB
		Menu, HotkeyTreeMButton, Uncheck, Spam E
	}
	
	if (HoldESpam = 1)
		Menu, HotkeyTreeE, Check, Hold E to Spam
	else
		Menu, HotkeyTreeE, Uncheck, Hold E to Spam
return


MoveWindow:
	if (FollowingChat=1){
		WinGet windows, List
		Loop %windows%
		{
			id := windows%A_Index%
			WinGetTitle, FoundWindow, ahk_id %id%
			if RegexMatch(FoundWindow, "- Twitch - Google Chrome") 
			{
				TwitchWindow := FoundWindow
				TwitchID := id
			}
		}
		WinGetPos, TwitchX, TwitchY, TwitchW, TwitchH, %TwitchWindow%
		WinGetPos, WFAX, WFAY, WFAW, WFAH, Warframe AIO
		WinGetPos, AX, AY, AW, AH, A
		WinGetTitle, WindowCurrent, A
		WinGetTitle, TwitchWindowCurrent, ahk_id %TwitchID%
		
		;Tooltip, %WindowCurrent%
		;Tooltip, Active`tWFA`n%AX%`t%WFAX%`n%AY%`t%WFAY%`n%AW%`t%WindowW%`n%AH%`t%WindowH%

		if (WFAX>-32000 && WFAY>-32000){
					
			if ((TwitchX>=AX && TwitchX<=AX+AW) or (WFAX>=AX && WFAX<AX+AW) or (WFAX<=AX && AX<=WFAX+WindowW-10) or !inStr(TwitchWindowCurrent,TwitchWindow) or inStr(TwitchWindow,"Following")) && !inStr(TwitchWindow,WindowCurrent) && !WinActive("Warframe AIO") && !inStr(WindowCurrent,"Program Manager")
			{
				GoSub, MinimizeWindow
			}
			else if (LastPosX!=TwitchX or LastPosY!=TwitchY or LastPosW!=TwitchW or LastPosH!=TwitchH)
			{
				LastPosX:=TwitchX
				LastPosY:=TwitchY
				LastPosW:=TwitchW
				LastPosH:=TwitchH
				
				WindowX:=LastPosX+LastPosW-347
				WindowY:=LastPosY+160
				WinRestore, Warframe AIO
				WinMove, Warframe AIO, , WindowX, WindowY, WindowW, WindowH
				;Tooltip, %TwitchX%`n%TwitchY%`n%TwitchW%`n%TwitchH%
			}
		}
	}else{
		IniRead, WindowX, %FileSettings%, Main, X
		IniRead, WindowY, %FileSettings%, Main, Y
		IniRead, WindowW, %FileSettings%, Main, W
		IniRead, WindowH, %FileSettings%, Main, H
		WinRestore, Warframe AIO
		WinMove, Warframe AIO, , WindowX, WindowY, WindowW, WindowH
	}
	
return


ShowCustomHotkeyGUI:
	Gui, CHK:New, -MinimizeBox -MaximizeBox, Set Custom Hotkey
	Gui, CHK:Add, Text, x5, Initiate Hotkey:
	Gui, CHK:Add, Edit, x85 w50 y4 vInHotkey, %SetHotkey%
	Gui, CHK:Add, Text, x5 y30, Output Key:
	Gui, CHK:Add, Edit, x85 w50 y28 vInOutputKey, %SetOutputKey%
	Gui, CHK:Add, Text, x5 y60, Time Delay (s):
	Gui, CHK:Add, Edit, x85 w50 y52 vInHotkeyTime, %SetHotkeyTime%
	Gui, CHK:Add, Button, x5 y100 w130 Default gUpdateCustomHotkey, Set
	Gui, CHK:Show
return

UpdateCustomHotkey:
	Gui, CHK:Submit
	Hotkey, %SetHotkey%, Off
	Hotkey, %InHotkey%, CustomButton
	SetHotkey := InHotkey
	SetOutputKey := InOutputKey
	SetHotkeyTime := InHotkeyTime
	HotKeyTimeMS := floor(SetHotkeyTime*1000)
return

CustomButton:
	Send {%SetHotkey%}
	;if (WinActive("ahk_exe warframe.x64.exe"))
	;{
		if (CustomHotkeyON=0)
		{
			SoundBeep
			CustomHotkeyON=1
			SetTimer, CustomSpam, %HotkeyTimeMS%
		}
		else
		{
			SoundBeep
			SoundBeep
			CustomHotkeyON=0
			SetTimer, CustomSpam, Off
		}
	;}
return

CustomSpam:
	Send {%SetOutputKey%}
return

MoveButtonFn:
	FollowingChat := 1
	GoSub, ChatButtonFn
	global MoveNow := 1
	
return

ChatButtonFn:
	if (FollowingChat=1){
		FollowingChat := 0
		SetTimer, MoveWindow, Off
		MakeChat(ChatButton,Color[4],2)
		GoSub, MoveWindow
	}else{
		FollowingChat := 1
		SetTimer, MoveWindow, 500
		MakeChat(ChatButton,Color[4],4)
	}
	IniWrite, %FollowingChat%, %FileSettings%, Main, FollowingChat
return
UpArrowFn:
	if (WindowH>WindowHmin+WindowInc)
		WindowH := WindowH-WindowInc
	else
		WindowH := WindowHmin
	GoSub, ResizeWindow
return
DownArrowFn:
	if (WindowH<WindowHmax-WindowInc)
		WindowH := WindowH+WindowInc
	else
		WindowH := WindowHmax
	GoSub, ResizeWindow
return
ResizeWindow:
	GuiControl, Move, HTMLDisplay, X0 Y%ActiveXY% W%WindowW% H%WindowH%
	WinMove, Warframe AIO, , WindowX, WindowY, WindowW, WindowH
	HTMLDisplay.document.parentWindow.ResizeDivs("maintabcontent", WindowH-150)
	IniWrite, %WindowH%, %FileSettings%, Main, H
return

SettingsFn:

return


class WB_events {
	BeforeNavigate2(wb, NewURL) {
		;wb.Stop()
		if (InStr(NewURL,"myapp")) {
			if (InStr(NewURL,"Alerts"))
				CurrentTab := "Alerts"
			else if (InStr(NewURL,"Fissures"))
				CurrentTab := "Fissures"
			else if (InStr(NewURL,"Invasions"))
				CurrentTab := "Invasions"
			else if (InStr(NewURL,"Rewards"))
				CurrentTab := "Rewards"
			else if (InStr(NewURL,"Missions"))
				CurrentTab := "Missions"
			else if (InStr(NewURL,"Rivens"))
				CurrentTab := "Rivens"
			else if (InStr(NewURL,"Prices"))
				CurrentTab := "Prices"
			;Tooltip, %CurrentTab%
			GoSub, ManageMainTabs
		}
	}
}

HideAllControls:
	GuiControl, Hide, RivenInput
	GuiControl, Hide, RivenText
	GuiControl, Hide, RivenButton
	GuiControl, -Default, RivenButton
	;==============================
	GuiControl, Hide, RelicText
	GuiControl, Hide, RelicIn
	GuiControl, Hide, RelicChoice
	GuiControl, Hide, LookupButton
	GuiControl, -Default, LookupButton
	;==============================
	GuiControl, Hide, ItemsText
	GuiControl, Hide, RewardItems
	GuiControl, Hide, TypeText
	GuiControl, Hide, MissionTypes
	GuiControl, Hide, ShowText
	GuiControl, Hide, AllResults
	GuiControl, Hide, ShortResults
	GuiControl, Hide, MissionButton
	GuiControl, -Default, MissionButton
	;==============================
	GuiControl, Hide, PriceText
	GuiControl, Hide, ItemName
	GuiControl, Hide, PriceButton
	GuiControl, -Default, PriceButton
return
ManageMainTabs:
	GoSub, HideAllControls
	if (CurrentTab="Rivens"){
		GuiControl, Show, RivenInput
		GuiControl, Show, RivenText
		GuiControl, Show , RivenButton
		GuiControl, +Default, RivenButton
	}else if (CurrentTab="Rewards" || CurrentTab="Relics"){
		GuiControl, Show, RelicText
		GuiControl, Show, RelicIn
		GuiControl, Show, RelicChoice
		GuiControl, Show, LookupButton
		GuiControl, +Default, LookupButton
	}else if (CurrentTab="Missions"){
		GuiControl, Show, ItemsText
		GuiControl, Show, RewardItems
		GuiControl, Show, TypeText
		GuiControl, Show, MissionTypes
		GuiControl, Show, ShowText
		GuiControl, Show, AllResults
		GuiControl, Show, ShortResults
		GuiControl, Show, MissionButton
		GuiControl, +Default, MissionButton
	}else if (CurrentTab="Prices"){
		GuiControl, Show, PriceText
		GuiControl, Show, ItemName
		GuiControl, Show, PriceButton
		GuiControl, +Default, PriceButton
	}
return
;====================================================
SplashFn:
	if (A_GuiEvent = "Normal")
		WM_LBUTTONUP()
	if (A_GuiEvent = "DoubleClick"){
		FileSelectFile, FilePointer, 1, %A_ScriptDir%\Images, Select Icon, *.png;*.jpg;*.gif
		if (ErrorLevel!=1){
			SplashClickW := MakeSplash(Splash, Color[3], FilePointer)
			GuiControl, MoveDraw, Splash, x%SplashX% y%SplashY% w%SplashW% h%SplashH%
			GuiControl, MoveDraw, SplashClick,  w%SplashClickW%
			GoSub, UpdateCetus
		}
	}
return
;=================================================
UpdateCetus:
	GuiControl, , CetusText, %CetusStr%
	if InStr(CetusStr, "night",0)
		GuiControl, , CetusIcon, %SunIcon%
	else
		GuiControl, , CetusIcon, %MoonIcon%
return
;===============================================
UpdateAPI:
	UrlDownloadToFile, https://api.warframestat.us/pc, WF.json
	FileRead, WFjson, WF.json
	;======CETUS TIMER==============
	FoundPos := RegexMatch(WFjson, "O):[ ]?""(.+?)""", Match, InStr(WFjson, "shortString",0,1))
	CetusStr := Match[1]
	GoSub, UpdateCetus
	HTMLalerts := Rewards := BaroHTML := EventsHTML := "", BarColor := []
	TotalWidth := WindowW*0.925
	BarColor[1] := "408156", BarColor[2] := "BD2A33"
	;==============ALERTS============
	FoundPos := RegexMatch(WFjson, "O)alerts"":[ ]?\[\{(.+?)\],[\n]?[\t]?""sortie", Match) ;;;;,Clipboard := Match[1]
	AlertsArray := strSplit(Match[1], "{""id")
	Loop % AlertsArray.MaxIndex(){
		AlertInfoArray := strSplit(AlertsArray[A_Index], ",")
		FilePath := FilePath2 := node := type := faction := credits := itemString := thumbnail := minEnemyLevel := maxEnemyLevel := archwingRequired := eta := ""
		Loop % AlertInfoArray.MaxIndex(){
			FoundPos := RegexMatch(AlertInfoArray[A_Index],"O)""(.+?)"":""(.+?)""",Match)
			if (FoundPos>0){
				if (Match[1]="node")
					node := Match[2]
				else if (Match[1]="type" && type="")
					type := Match[2]
				else if (Match[1]="faction")
					faction := Match[2]
				else if (Match[1]="itemString")
					itemString := Match[2]
				else if (Match[1]="thumbnail")
					thumbnail := Match[2]
				else if (Match[1]="archwingRequired")
					archwingRequired := Match[2]
				else if (Match[1]="eta")
					eta := Match[2]
			}
			FoundPos := RegexMatch(AlertInfoArray[A_Index],"O)""(.+?)"":([0-9,]{1,6})",Match)
			if (FoundPos>0){
				if (Match[1]="credits")
					credits := Match[2], credits := RegExReplace(credits, "([0-9]{1})00$", ".$1K")
				else if (Match[1]="minEnemyLevel")
					minEnemyLevel := Match[2]
				else if (Match[1]="maxEnemyLevel")
					maxEnemyLevel := Match[2]
			}
		}
		node := node="" ? substr(AlertInfoArray[6], Instr(AlertInfoArray[6], """:""")+3, -1) : node
		FoundPos := Instr(eta,"m")
		eta := FoundPos>0 ? substr(eta,1,FoundPos) : eta
		URL := StrReplace(itemString, " ", "_")
		URL := RegExReplace(URL, "^(Dagger)_(Axe)_(Scindo)_(Skin)$", "$3_$1-$2_$4")
		URL := RegExReplace(URL, "^.+?(Manticore).+?$", "$1")
		URL := RegExReplace(URL, "i)^emp", "EMP")
		URL := RegExReplace(URL, "i)_systems|_chassis|_neuroptics")
		URL := RegExReplace(URL, "i)^.+?riven.+?$", "Riven_Mods")
		if (strLen(URL)>1){
			URL := RegExReplace(URL, "i)_Blueprint|[0-9]{1,4}_")
			FilePath := A_ScriptDir . "\Images\Rewards\" . URL . ".png"
			FilePath2 := A_ScriptDir . "\Images\Rewards\" . URL . "_" . RewardImgW . ".png"
			if (!FileExist(FilePath) || !FileExist(FilePath2)){
				URL := DownloadPageGetImage(URL)
				FilePath2 := DownloadAndResize(FilePath, URL, 1, RewardImgW)
			}
		}
		if (credits!="" && minEnemyLevel!="" && maxEnemyLevel!="" && !InStr(eta, "-")){
			SpeechStr := RegExReplace(itemString, "[0-9]{1,6} ")
			if (!Instr(UnwantedItems, SpeechStr))
				Rewards := Rewards . "," . SpeechStr
				
			itemString := StrReplace(itemString, " Blueprint")
			Reward := itemString="" ? credits . " " . CredIMG : "<b>" . itemString . "</b></td></tr><tr><td>" . credits . " " . CredIMG
			RowSpan := itemString="" ? 4 : 5
			archwinghtml := archwingRequired="true" ? "(A) " : ""
			thumbnail := FilePath2!="" ? FilePath2 : DownloadAndResize(A_ScriptDir . "\Images\Rewards\Credits.png", A_ScriptDir . "\Images\Rewards\Credits.png", 1, RewardImgW)
			thumbnailHuge := FilePath="" ? A_ScriptDir . "\Images\Rewards\Credits.png" : FilePath
			thumbnailHuge := StrReplace(thumbnailHuge, "\", "/")
			L0 := "<td rowspan=""" . RowSpan . """  align=""center"">`r`n<img src=""" . thumbnail . """ class=""reward"" onmouseover=""ShowHugeIMG('" . thumbnailHuge . "')"" onmouseout=""HideHugeIMG()"">`r`n</td>`r`n"
			L1 := "<tr><td><b>" . node . "</b> Lvl " . minEnemyLevel . "-" . maxEnemyLevel . "</td></tr>`r`n"
			L2 := "<tr><td><b>" . archwinghtml . type . " - " . faction . "</b></td></tr>`r`n"
			L3 := "<tr><td>" . Reward . "</td></tr>`r`n"
			L4 := "<tr id=""TimeRow""><td align=""center"" colspan=""2"">" . eta . "</td></tr>`r`n"
			HTMLalerts := HTMLalerts . "`r`n<table id=""Alert"">`r`n" . L0 . L1 . L2 . L3 . L4 . "`r`n</table>`r`n<br>`r`n"
		}
	}
	HTMLalerts := "<table id=""AlertsTable"">`r`n" . HTMLalerts . "`r`n</table>`r`n"
	;==============Events====================
	FoundPos := RegexMatch(WFjson, "O)events"":[ ]?\[\{(.+?)\],[\n]?[\t]?""alerts", Match) ;,Clipboard := Match[1]
	AlertsArray := strSplit(RegexReplace(Match[1],""""), "id:")
	Loop % AlertsArray.MaxIndex(){
		if (StrLen(AlertsArray[A_Index])>25){
			FoundPos := RegexMatch(AlertsArray[A_Index], "O)Node:(.+?)\,", Nodes)
			FoundPos := RegexMatch(AlertsArray[A_Index], "O)description:(.+?)\,", Desc)
			FoundPos := RegexMatch(AlertsArray[A_Index], "O)asString:(.+?)\,", Reward), Reward := Reward[1]
			FoundPos := RegexMatch(AlertsArray[A_Index], "O)health:(.+?)\,", Health)
			Reward := RegExReplace(Reward, "cr$", CredIMG)
			Reward := RegExReplace(Reward, "000<", "K<")
			FoundPos := RegExMatch(Reward, "O)^(.+?) \+", Match)
			if (FoundPos>0){
				URL := A_ScriptDir . "\Images\Rewards\" . RegExReplace(Match[1], " ", "_") . "_" . RewardImgW . ".png"
				if (FileExist(URL))
					Reward := RegExReplace(Reward, "^(.+?) \+", "<img src=""" . URL . """> +")
			}
			Percent1 := round(Health[1],1), Percent2 := round(100.0-Percent1,2) 
			Width1 := floor(TotalWidth*Percent1*0.01), Width2 := floor(TotalWidth*Percent2*0.01)
			if (Percent1>10.1)
				Percent1 := Percent1 . "%", Percent2 := "" 
			else
				Percent2 :=  Percent1 . "%", Percent1 :=""
			ProgressRow := "`r`n<tr><td>`r`n<table>`r`n<tr>`r`n
			<td style=""padding:1px 4px;background-color:#" . BarColor[1] . ";width:" . Width1 . "px;font-weight:bold;color:white;text-align:left;"">" . Percent1 . "</td>`r`n
			<td style=""padding:1px 4px;background-color:#" . BarColor[2] . ";width:" . Width2 . "px;font-weight:bold;color:white;text-align:left;"">" . Percent2 . "</td>`r`n</tr>`r`n</table>`r`n</td></tr>`r`n"
			
			if (Percent2!="0.0%")
				EventsHTML := EventsHTML . "`r`n<table id=""Events"">`r`n<tr><td>" . Nodes[1] . "</td></tr>`r`n<tr><td>" . Reward . "</td></tr>`r`n`r`n<tr><td>" . Desc[1] . "</td></tr>`r`n" . ProgressRow . "</table>`r`n<br>`r`n"
		}
	}
	;if (StrLen(EventsHTML)>50)
	;	EventsHTML := "`r`n<p><b>Events</b></p>" . EventsHTML
	;==================BARO KI TEER===========================
	FoundPos := RegexMatch(WFjson, "O)voidTrader"":[ ]?\{(.+?)}\,[\n]?[\t]?""dailyDeals", Match) ;;;,Clipboard := Match[1]
	if InStr(Match[1], """active"":true"){
		FoundPos := RegexMatch(Match[1], "O)endString"":[ ]?""(.+?)""", Time)
		FoundPos := Instr(Match[1],"{")+1, FoundPos2 := Instr(Match[1],"}]")
		BaroHTML := substr(Match[1], FoundPos, FoundPos2-FoundPos) ;, Clipboard := BaroHTML
		AlertsArray := strSplit(BaroHTML, "},{"), BaroHTML := ""
		Loop % AlertsArray.MaxIndex(){
			BaroHTML := BaroHTML . "`n<tr>"
			ArraySplit := strSplit(RegexReplace(AlertsArray[A_Index],""""), ",")
			Loop % ArraySplit.MaxIndex()
				BaroHTML := BaroHTML . "<td>" . substr(RegExReplace(ArraySplit[A_Index], "000$", "K"), InStr(ArraySplit[A_Index],":")+1) . "</td>"
			BaroHTML := BaroHTML . "</tr>"
		}
		BaroHTML := "`r`n<p><b>Baro Ki'Teer - " . Time[1] . "</b></p>`r`n<table id=""Baro"">`n<tr><th>Item</th><th>" . DucatIMG . "</th><th>" . CredIMG . "</th>`n</tr>" . BaroHTML . "`n</table>"
	}else{
		FoundPos := RegexMatch(Match[1], "O)startString"":[ ]?""(.+?)""", Time)
		BaroHTML := "`r`n<p><b>Baro Ki'Teer arives in " . RegExReplace(Time[1], "[ ]?[0-9]{1,2}s$") . "</b></p>"
	}
	;===============VOID FISSURES=======================
	FoundPos := RegexMatch(WFjson, "O)fissures"":[ ]?\[(.+?)\]", Match) ;,Clipboard := Match[1]
	AlertsArray := strSplit(RegexReplace(Match[1],""""), ",{"), FissuresHTML := ""
	Loop % AlertsArray.MaxIndex(){
		FoundPos := RegexMatch(AlertsArray[A_Index], "O)node:(.+?) (.+?)\,", Nodes)
		FoundPos := RegexMatch(AlertsArray[A_Index], "O)missionType:(.+?)\,", Type)
		FoundPos := RegexMatch(AlertsArray[A_Index], "O)enemy:(.+?)\,", Enemy)
		FoundPos := RegexMatch(AlertsArray[A_Index], "O)tierNum:(.+?)\,", TierNum)
		FoundPos := RegexMatch(AlertsArray[A_Index], "O)tier:(.+?)\,", Tier)
		FoundPos := RegexMatch(AlertsArray[A_Index], "O)eta:(.+?)\}", Time)
		FissuresHTML := FissuresHTML . TierNum[1] . "<tr><td>" . Nodes[1] . "<br>" . Nodes[2] . "</td><td>" . Type[1] . "<br>(" . Enemy[1] . ")</td><td>" . Tier[1] . "</td><td>" . RegExReplace(Time[1], "[0-9]{1,2}s") . "</td></tr>`n"
	}
	Sort, FissuresHTML
	FissuresHTML := "`r`n<div class=""maintabcontent"" id=""Fissures"">`r`n<table id=""Fissures"">`n<tr><th>Node</th><th>Type</th><th>Tier</th><th>Time</th>`n</tr>" . RegexReplace(FissuresHTML, "[0-9]<tr>", "<tr>") . "`n</table>`n</div>`n"
	;=================INVASIONS========================
	FoundPos := RegexMatch(WFjson, "O)invasions"":\[\{(.+?)\}\],""darkSectors", Match)
	AlertsArray := strSplit(RegexReplace(Match[1],""""), "},{")
	InvasionsHTML := LastPlace := "", Tables := [], j := 0
	Loop % AlertsArray.MaxIndex(){
		if (RegexMatch(AlertsArray[A_Index], "completed:false")){
			i := A_Index
			FoundPos := RegexMatch(AlertsArray[i], "O)node:(.+?) \((.+?)\)\,", Nodes)
			FoundPos := RegexMatch(AlertsArray[i], "O)desc:(.+?)\,", Desc)
			FoundPos := RegexMatch(AlertsArray[i], "O)attackingFaction:(.+?)\,", Enemy1)
			FoundPos := RegexMatch(AlertsArray[i], "O)defendingFaction:(.+?)\,", Enemy2)
			FoundPos := RegexMatch(AlertsArray[i], "O)completion:(.+?)\,", Percent)
			Percent1 := round(Percent[1],2), Percent2 := round(100.0-Percent1,2) 
			Width1 := floor(TotalWidth*Percent1*0.01), Width2 := floor(TotalWidth*Percent2*0.01)
			Percent1 := Percent1>100 ? 100 : Percent1
			Percent2 := Percent2>100 ? 100 : Percent2
			Padding1 := Percent1<8 ? "1px 0px" : "1px 4px"
			Percent1 := Percent1<8 ? "" : round(Percent1,1) . "%"
			Padding2 := Percent2<8 ? "1px 0px" : "1px 4px"
			Percent2 := Percent2<8 ? "" : round(Percent2,1) . "%"
			Loop, 2 {
				FoundPos2 := A_Index=1 ? 1 : InStr(AlertsArray[i], "},")
				FoundPos := RegexMatch(AlertsArray[i], "O)asString:(.+?)\,", Item%A_Index%, FoundPos2)
				FoundPos := RegexMatch(AlertsArray[i], "O)thumbnail:(.+?)\,", Image%A_Index%, FoundPos2)
				Item := RegExReplace(Item%A_Index%[1], "[0-9] ")
				Item := RegExReplace(Item, "i)[ ]?(Barrel|Blade|Blueprint|Heatsink|Hilt|Receiver|Stock)")
				Image := Image%A_Index%[1]
				if (!InStr(Item%A_Index%[1],"itemString")){
					URL := (substr(Image,1,1)="," || RegExMatch(Item, "i)vandal|wraith")) ? DownloadPageGetImage(Item) : Image
					FilePath := A_ScriptDir . "\Images\Invasions\" . Item . ".png"
					URL%A_Index% := DownloadAndResize(FilePath, URL, 1, 80)
				}
			}
			BarColor := []
			BarColor[1] := Enemy1[1]="Grineer" ? "BD2A33" : Enemy1[1]="Infested" ? "408156" : "2B5166"
			BarColor[2] := Enemy2[1]="Grineer" ? "BD2A33" : Enemy2[1]="Infested" ? "408156" : "2B5166"
			ProgressRow := "`r`n<tr><td colspan=""10"">`r`n<table style=""width:" . TotalWidth . "px;"">`r`n<tr>`r`n
			<td style=""padding:" . Padding1 . ";background-color:#" . BarColor[1] . ";width:" . Width1 . "px;font-weight:bold;color:white;text-align:left;"">" . Percent1 . "</td>`r`n
			<td style=""padding:" . Padding2 . ";background-color:#" . BarColor[2] . ";width:" . Width2 . "px;font-weight:bold;color:white;text-align:right;"">" . Percent2 . "</td>`r`n</tr>`r`n</table>`r`n</td></tr>`r`n"

			L1 := "`r`n<tr><td colspan=""10"" style=""text-align:left;"">" . Nodes[1] . "</td></tr>"
			if (InStr(Item1[1],"itemString"))
				L2 := "`r`n<tr>`r`n<td>" . Enemy1[1] . "</td>`r`n<td style=""width:" . WidthSmall . "px""><img src=""" . URL2 . """ title=""" . Item2[1] . """></td>`r`n<td>" . Enemy2[1] . "</td>`r`n</tr>"
			else
				L2 := "`r`n<tr>`r`n<td>" . Enemy1[1] . "</td><td>" . Enemy2[1] . "</td>`r`n</tr>`r`n<tr><td><img src=""" . URL1 . """  title=""" . Item1[1] . """></td><td><img src=""" . URL2 . """ title=""" . Item2[1] . """></td>`r`n</tr>"

			if (LastPlace!=Nodes[2]){
				FoundPos := 0
				Loop % Tables.MaxIndex(){
					if (FoundPos=0){
						FoundPos := InStr(Tables[A_Index],Nodes[2])
						j := FoundPos>0 ? A_Index : j
					}
				}
				if (FoundPos=0)
					j := j+1, Tables[j] := Tables[j] . "`r`n<table id=""Invasion"">`r`n<tr><td colspan=""10"">" . Nodes[2] . " - " . Desc[1] . "</td></tr>`r`n"
				LastPlace := Nodes[2]
			}
			Tables[j] := Tables[j] . L1 . ProgressRow . L2 . "`r`n"
		}
		SpeechStr := RegExReplace(Item1[1], "[0-9]{1,6} ")
		SpeechStr2 := RegExReplace(Item2[1], "[0-9]{1,6} ")
		if (!Instr(UnwantedItems, SpeechStr) && !Instr(Rewards, SpeechStr) && !InStr(Item1[1],"itemString"))
			Rewards := Rewards . "," . SpeechStr
		if (!Instr(UnwantedItems, SpeechStr2) && !Instr(Rewards, SpeechStr2))
			Rewards := Rewards . "," . SpeechStr2
	}
	Loop % Tables.MaxIndex(){
		if (A_Index!=1)
			InvasionsHTML := InvasionsHTML . "`r`n</table>`r`n<br>"
		InvasionsHTML := InvasionsHTML . "`r`n" . Tables[A_Index]
	}
	InvasionsHTML := "`r`n<div class=""maintabcontent"" id=""Invasions"">`r`n" . InvasionsHTML . "`n</div>`n"
	;==============REFRESH HTML/JS PROPERLY===================
	HTMLDisplay.document.getElementById("Alerts").innerHTML := "`r`n<div class=""maintabcontent"" id=""AlertsAlerts"">`r`n" . EventsHTML . HTMLalerts . BaroHTML . "`r`n</div>" . FissuresHTML . InvasionsHTML
	if (CurrentTab="Alerts")
		HTMLDisplay.document.parentWindow.openTabMain("Alerts","AlertsAlerts")
	else if (CurrentTab="Fissures")
		HTMLDisplay.document.parentWindow.openTabMain("Alerts","Fissures")
	else if (CurrentTab="Invasions")
		HTMLDisplay.document.parentWindow.openTabMain("Alerts","Invasions")
	;====================================================
	file := FileOpen("Text2Speak.txt", "w"), file.Write(Substr(Rewards,2)), file.Close()
	AlertsArray := ArraySplit := BaroHTML := HTMLalerts := InvasionsHTML := WFjson := ""
return

SpeakAlerts:
	if (UseVoice)
		Run, Speak.ahk
return
;===============================================
LookupMissions:
	HTMLDisplay.document.getElementById("Missions").innerHTML := "Please be patient, this may take a while..."
	FileName := A_ScriptDir . "\WF-drops.json"
	;if (!FileExist(FileName))
		UrlDownloadToFile, https://api.warframestat.us/drops, %FileName%
	FileRead, WFjson, %FileName%
	WFjson := RegExReplace(WFjson, """")
	MissionsHTML := SubStr(WFjson,3,StrLen(WFjson)-4), Array := strSplit(MissionsHTML, "},{")
	LastPlace := LastRot := MissionsHTML := PreviousMissions := "", i := 0, Tables := []
	Loop % Array.MaxIndex(){
		FoundPos := RegexMatch(Array[A_Index], "O)place:(.+?),[ ]?(Rot )?(.+?)?[,]?item:(.+?),rarity:(.+?),chance:([0-9.]{1,9})", Match)
		Place := Match[1], Rot := Match[3], Chance := Match[6]
		Item := RegExReplace(Match[4], " Relic| Cache| Scene| Coordinate")
		if (!InStr(PreviousMissions,Place)){
			if (LastPlace!=Place && Place!=""){
				if (i>0){
					Tables[i] := Tables[i] . "`r`n</table>"
					PreviousMissions := PreviousMissions . "," . LastPlace
				}
				LastPlace := Place, i := i+1
				Tables[i] := Tables[i] . "`r`n<table id=""Mission"">`r`n<tr><th id=""title"" colspan=""2"">" . Place . "</th></tr>"
			}
			if (LastRot!=Rot && Rot!=""){
				LastRot := Rot
				Tables[i] := Tables[i] . "`r`n<tr><th colspan=""2"">Rotation " . Rot . "</th></tr>"
			}
			if (Item!="")
				Tables[i] := Tables[i] . "`r`n<tr><td>" . Item . "</td><td>" . Chance . " %</td></tr>"
		}
	}
	Tables[i] := Tables[i] . "`r`n</table>"
	GuiControlGet, Items, , RewardItems
	GuiControlGet, Types, , MissionTypes
	GuiControlGet, All, , AllResults
	Array := strSplit(RegExReplace(Items, ",[ ]{0,10}", ","), ",")
	Loop % Tables.MaxIndex(){
		i := A_Index, j := 0
		if (RegExMatch(Tables[i], "i)(" . RegExReplace(Types, ",[ ]{0,10}", ")|(") . ")")>0){
			if (Items!=""){
				Loop % Array.MaxIndex(){
					k := A_Index, FoundPos := RegexMatch(Tables[i], "i)" . Array[k])
					While (FoundPos>0)
						j := j+1, FoundPos := RegexMatch(Tables[i], "i)(" . Array[k] . ")", , FoundPos+3)
				}
				if (j>0){
					Tables[i] := RegExReplace(Tables[i], "i)<th id=""title"" colspan=""2"">(.+?)</th>", "<th id=""title"" colspan=""2"">$1 (" . j . ")</th>")
					MissionsHTML := MissionsHTML . "|" .  j . Tables[i] . "<br>"
				}
			}else
				MissionsHTML := MissionsHTML . Tables[i] . "<br>"
		}
	}
	if (MissionsHTML!=""){
		if (Items!=""){
			Sort, MissionsHTML, D| R
			MissionsHTML := RegExReplace(MissionsHTML, "\|([0-9]{1,5})?")
			MissionsHTML := SubStr(MissionsHTML, InStr(MissionsHTML, "<"))
			if (!All)
				MissionsHTML := RegExReplace(MissionsHTML, "i)(<tr><td>[a-z0-9'\- \(\)]{4,50})(?<!" . RegExReplace(Items, ",[ ]{0,10}", "|") . ")</td><td>.+?</td></tr>[\r\n]")
			Loop % Array.MaxIndex()
				MissionsHTML := RegExReplace(MissionsHTML, "i)" . Array[A_Index], "<font color=""#" . Color[1] . """><b>$0</b></font>")
		}
	}else
		MissionsHTML := "No Results Found, Try Again"
	HTMLDisplay.document.getElementById("Missions").innerHTML := MissionsHTML
	MissionsHTML := Tables := ""
return

LookupRelics:
	GuiControlGet, Relics, , RelicIn
	Relics := RegexReplace(Relics, "[ ]{0,10},[ ]{0,10}", ",")
	Relics := RegexReplace(Relics, "i)([a-z]{1})([a-z]{2,3})[ ]{0,10}([a-z]{1})", "$U1$L2 $U3")
	
	HTMLrelics := ""
	if (InStr(Relics,",")) {
		Relics := StrSplit(Relics,",")
		Loop % Relics.MaxIndex()
			HTMLrelics := HTMLrelics . GetRelicHTML(Relics[A_Index])
	}
	else
		HTMLrelics := HTMLrelics . GetRelicHTML(Relics)
	HTMLDisplay.document.getElementById("Rewards").innerHTML := HTMLrelics
return

GetPlayersRelics:
	SoundBeep
	File := "Capture.txt", RelicsToSearch := "", FoundPos := 1, Pos1X:=130, Pos2X:=40, PosY:=80
	if !WinActive("ahk_exe warframe.x64.exe"){
		WinActivate, ahk_exe warframe.x64.exe
		MouseMove, Pos2X, PosY
		MouseClick, Left
		Sleep 500
	}
	PixelGetColor, MenuTestColor,  A_ScreenWidth*.92, A_ScreenHeight*.927
	if (MenuTestColor!="0xF9F9F9" || MenuTestColor!="0xFFFFFF"){
		Send {Esc}
		Sleep 600
	}
	PixelGetColor, MenuTestColor,  A_ScreenWidth*.92, A_ScreenHeight*.927
	Sleep 600
	if (MenuTestColor="0xF9F9F9" || MenuTestColor="0xFFFFFF"){
		MouseMove, Pos2X, PosY
		Sleep 200
		RunWait, %A_ScriptDir%\Capture2Text\Capture2Text_CLI.exe --debug --screen-rect "100 110 1100 300" -o %File% --scale-factor 4.0,,Hide
		FileCopy, Capture2Text\debug_enhanced.png, Capture.png, 1		;;Copy Debug Image File for each
		if FileExist(File){
			FileRead, Contents, %File%
			Loop, 4{
				FoundPos := RegexMatch(Contents, "O)([ALMN][EIX1\|][IlOST01\|][OH0 ])[ ]{1,5}([A-Z0-9]{2,4})",Match,FoundPos+2)
				if (FoundPos>0) {
					Tier := Match[1], Relic := RegexReplace(Match[2], "[_ ]"), Relic := RegexReplace(Relic, "I3", "B")
					Char1 := substr(Relic,1,1), Char2 := substr(Relic,2)
					Tier := StrReplace(Tier,"AXl","AXI")
					Char1 := Char1 == "2" ? "Z" : Char1
					Char1 := Char1 == "3" || Char1 == "8" ?	"B" : Char1
					Char1 := Char1 == "0" ? "O" : Char1
					Char1 := Char1 == "`$" ? "S" : Char1
						
					Char2 := (Char2 = "'l" || Char2 = "'I" || Char2 = "I" || Char2 = "T")	? "1" : Char2		
					Char2 := (Char2 = "Z") ? "2" : Char2
					Char2 := (Char2 = "S")	? "5" : Char2
					Char2 := (Char2 = "B")	? "3" : Char2
					Tier := RegExReplace(Tier, "([a-zA-Z]{1})([a-zA-Z]{2,3})[ ]{1,10}","$U1$L2")
					RelicFound := Tier . " " . Char1 . Char2
					;oVoice.Speak(RelicFound)
					if (!InStr(RelicsToSearch,RelicFound))
						RelicsToSearch := RelicsToSearch="" ? RelicFound : RelicFound . "," . RelicsToSearch 
				}
			}
			RelicsArray := StrSplit(RelicsToSearch, ",")
			;oVoice.Speak(RelicsArray.MaxIndex()-1 . " Relics Found")
			;if (RelicsArray.MaxIndex()>=4)
			;	RelicsToSearch := substr(RelicsToSearch,InStr(RelicsToSearch, ",", 0, 0)-1)
		}
	}else
		oVoice.Speak("Unable to get pause menu")
	SoundBeep
	Send {Esc}
return

GetRelicHTML(Relic){
	RelicURL := RegExReplace(Relic," ","_")
	FilePath := A_ScriptDir . "\Pages\" . RelicURL . ".html"
	if (!FileExist(FilePath))
		UrlDownloadToFile, http://warframe.wikia.com/wiki/%RelicURL%, %FilePath%
	FileRead, RelicHTML, %FilePath%
	Clipboard := RelicHTML
	if (RegExMatch(RelicHTML, "does not yet have a page with this exact name") or !RegexMatch(RelicURL, "^[A-Z]{1}[a-z]{2,3}_[A-Z]{1}[0-9]{1}$"))
		RelicHTML := "`n<table>`n<tr><td>`nError: The Relic """ . Relic . """ does not exist`n</td></tr>`n</table>"
	else{
		FoundPos := InStr(RelicHTML, "</th></tr>")+10
		FoundPos2 := InStr(RelicHTML, "<td colspan=""3"">")-5

		if (RegexMatch(RelicHTML, "no longer obtainable from the drop tables"))
			Relic := RegExReplace(Relic, "i)([a-z]{1})([0-9]{1})", "$1$2<br>*V*")
		else if (RegexMatch(RelicHTML, "is not available for purchase"))
			Relic := RegExReplace(Relic, "i)([a-z]{1})([0-9]{1})", "$1$2<br>*B*")
		Relic := RegExReplace(Relic, "i)([a-z]{3,4}) ", "$1<br>")
			
		RelicHTML := substr(RelicHTML,FoundPos,FoundPos2-FoundPos) . "</table>`n`n`n"

		RelicHTML := RegExReplace(RelicHTML, "<a.+?>|</a>|<br />|</noscript>| Prime|<img src=""data.+?<noscript>|<div.+?/div>|.rowspan="".+?""|<tr>.<td style=""background.+?</table>.</td></tr>")
		RelicHTML := RegExReplace(RelicHTML, "<td>[ ]?<span.+?</td>", "")
		RelicHTML := RegExReplace(RelicHTML, "<td style=""padding:0;"">.+?</td>", "`n")
		RelicHTML := RegExReplace(RelicHTML, "class="".+?>","class=""RelicReward""></td><td>")
		RelicHTML := RegExReplace(RelicHTML, "\.png.+?""", ".png""")
		StringReplace, RelicHTML, RelicHTML, Blueprint, BP,All
		FoundPos := 1
		While (FoundPos>0){
			FoundPos := RegexMatch(RelicHTML, "O)src=""(.+?)\.png",Match,FoundPos+1)
			if (FoundPos>0){
				URL := Match[1] . ".png"
				URL2 := URL . "/revision/latest/scale-to-height-down/" . RelicRewardImgH
				FoundPos2 := InStr(URL, "/", 0, -1)+1
				File := substr(URL, FoundPos2)
				FileName := "Images\RelicRewards\" . substr(File, 1, StrLen(File)-4)
				if (!FileExist(FileName . ".png") || !FileExist(FileName . "_Full.png")){
					UrlDownloadToFile, %URL%, %FileName%_Full.png
					UrlDownloadToFile, %URL2%, %FileName%.png
				}
				JavaURL := RegExReplace(A_ScriptDir . "/" . FileName . "_Full.png", "\\", "/")
				FoundPos2 := Instr(RelicHTML, URL, 0, FoundPos)
				if (FoundPos2>0){
					FoundPos3 := Instr(RelicHTML, """", 0, FoundPos2+1)
					if (FoundPos3>0){
						Inserter := A_ScriptDir . "\" . FileName . ".png""  onmouseout=""HideHugeIMG()"" onmouseover=""ShowHugeIMG('" . JavaURL . "')"
						RelicHTML := substr(RelicHTML,1,FoundPos2-1) . Inserter . substr(RelicHTML,FoundPos3)
					}
				}
			}
		}
		FoundPos := 1
		Loop, 6{
			FoundPos := InStr(RelicHTML,"<td>",0,FoundPos+1)
			if (FoundPos>0){
				CurrentColor := A_Index<4 ? "946A39" : A_Index=6 ? "CCB45F" : "CBCBCB"
				RelicHTML := substr(RelicHTML,1,FoundPos+2) . " style=""color:#" . CurrentColor . """" . substr(RelicHTML,FoundPos+3)
			}
		}
		RelicHTML := RegExReplace(RelicHTML, "<td style=""padding.+?"">", "<td>")
		RelicHTML := "<table id=""Relics"">`n<td style=""text-align:center;"" rowspan=""7""><font color=""#" . Color[1] . """>" . Relic . "</font></td>" . RelicHTML
	}
	return RelicHTML
}
;===============================================
SearchRiven:
	GuiControlGet, CurrentRiven, , RivenInput
	CurrentRiven2 := InStr(CurrentRiven, "rifle") ? "rifle riven" : InStr(CurrentRiven, "shotgun") ? "shotgun riven" : InStr(CurrentRiven, "pistol") ? "pistol riven" : InStr(CurrentRiven, "melee") ? "melee riven" : CurrentRiven
	CurrentRiven := RegexReplace(CurrentRiven,"^([a-zA-z])(.+?) ([a-zA-z])(.+?)$", "$U1$L2_$U3$L4")
	URL := "http://warframe.wikia.com/wiki/" . CurrentRiven
	FilePath := A_ScriptDir . "\Pages\" . CurrentRiven . ".html"
	if (!FileExist(FilePath))
		UrlDownloadToFile, %URL%, %FilePath%
	FileRead, WeaponHTML, %FilePath%
	FoundPos := InStr(WeaponHTML, "<div style=""font-size")
	FoundPos2 := InStr(WeaponHTML, "<div style=""overflow:",0,FoundPos)
	WeaponHTML := SubStr(WeaponHTML, FoundPos, FoundPos2-FoundPos)
	WeaponHTML := SubStr(WeaponHTML, InStr(WeaponHTML, "Statistics")+10)
	WeaponHTML := RegExReplace(WeaponHTML, "[\n]{0,5}|[\t]{0,5}|<span.+?<td>|</h3>|</?section.+?>|</noscript>|<img src=""data.+?<noscript>|<img.+?(Mastery|TopWeapon|MiniMapMod).+?>")
	WeaponHTML := RegExReplace(WeaponHTML, "</div></div>", "</td>`n</tr>`n")
	WeaponHTML := RegExReplace(WeaponHTML, "<div class=""pi-data.+?>", "</td><td>")
	WeaponHTML := RegExReplace(WeaponHTML, "<div class=""pi-item.+?>[\n\t]{0,5}", "`n<tr>`n<td>")
	WeaponHTML := RegExReplace(WeaponHTML, "</?a.+?>", "</td><td>")
	WeaponHTML := RegExReplace(WeaponHTML, "<h[23].+?>", "<td>")
	WeaponHTML := RegExReplace(WeaponHTML,	"</h[23]>", "</td>")
	WeaponHTML := RegExReplace(WeaponHTML,	"<table.+?><tbody><tr>", "`n</tr>`n<tr>`n<td>")
	WeaponHTML := RegExReplace(WeaponHTML, "</aside></div>", "</table>")
	WeaponHTML := RegExReplace(WeaponHTML, "<td>[ ]{0,5}</td>")
	WeaponHTML := RegExReplace(WeaponHTML, "<td>[ ]{0,5}<td>", "<td>")
	WeaponHTML := RegExReplace(WeaponHTML, "<td>[\n]{0,5}</tr>", "</tr>`n<tr>")
	WeaponHTML := RegExReplace(WeaponHTML, "[ ]{3,8}></td><td>[ ]{1,8}(\d)", "> $1")
	WeaponHTML := RegExReplace(WeaponHTML, "<span.+?></td>|<td class=""pi-horizontal.+?>")
	WeaponHTML := RegExReplace(WeaponHTML, "\(<td>", "(")
	WeaponHTML := RegExReplace(WeaponHTML, "</tr>[\n]{0,5}<td>", "</tr>`n<tr>`n<td>")
	WeaponHTML := RegExReplace(WeaponHTML, "<td><td>", "<td>")
	WeaponHTML := RegExReplace(WeaponHTML, "</tbody></table>", "`n<tr>`n")
	WeaponHTML := RegExReplace(WeaponHTML, "<td>(<img.+?> .+?)</td>", "$1 ")
	WeaponHTML := RegExReplace(WeaponHTML, "<tr>[\n]{0,5}<img", "<tr>`n<td>`n<img")
	WeaponHTML := RegExReplace(WeaponHTML, "</td><img", "</td><td><img")
	WeaponHTML := RegExReplace(WeaponHTML, "(<tr>[\n]{0,5})<td>([\n]{0,5}<img.+?>.+?<img.+?>.+?<img.+?>.+?[ ]?)</tr>", "$1<td align=""center"" colspan=""2"">$2</td>`n</tr>")
	FoundPos := RegexMatch(WeaponHTML, "<tr>[\n]{0,5}<td>Miscellaneous")
	if (FoundPos>0)
		WeaponHTML := SubStr(WeaponHTML, 1, FoundPos-1)
	WeaponHTML := RegExReplace(WeaponHTML, "(r|a|d)(ound|mmo|amage)[s]?[ ]?(p)?(er)?[ ]?(s|m|p)?(ec|ag|hot|ellet)?", "$U1$U3$U5")
	WeaponHTML := RegExReplace(WeaponHTML, "(Full|Min) D(up to|at)[ ](.+?)\.. m", "$1: $3m")
	WeaponHTML := RegExReplace(WeaponHTML, "i)max reduction", " Drop")
	WeaponHTML := RegExReplace(WeaponHTML, "Critical Chance", "CC")
	WeaponHTML := RegExReplace(WeaponHTML, "Critical multiplier", "CD")
	WeaponHTML := RegExReplace(WeaponHTML, "<td>(Barrage Mode|Cannon Mode Cluster Bombs|Cannon Mode Explosion|Cannon Mode Projectile|Charged Shot|Fully Spooled|Normal Attacks|Other Attacks|Secondary Attacks|Single Pellet|Toxin Cloud|Uncharged Shot|Utility)</td>", "<th colspan=""2"" align=""center""><font color=""#" . Color[1] . """>$1</font></th>")
	WeaponHTML := RegExReplace(WeaponHTML, "</th>[\n]{0,5}<tr>", "</th>`n</tr>`n<tr>")
	
	WeaponHTML := "<table id=""WeaponInfo"">`n<tr>`n" . WeaponHTML . "`n</table>"
	FoundPos := 1
	While (FoundPos>0){
		FoundPos := RegExMatch(WeaponHTML, "O)<img.+?src=""(.+?)""", Match, FoundPos+50)
		if (FoundPos>0){
			URL := SubStr(Match[1], 1, InStr(Match[1], "/revision")-1)
			RegExMatch(URL, "O)/[a-z0-9]{2}/(.+?)(.png|.svg)", Match2)
			FilePath := DownloadAndMatrix(A_ScriptDir . "\Images\Icons\" . Match2[1] . ".png", URL, Color[3])
			WeaponHTML := RegExReplace(WeaponHTML, RegExReplace(Match[1], "\?", "\?"), RegExReplace(FilePath, "\\", "\\"))
		}
	}
	HTMLDisplay.document.getElementById("Rivens").innerHTML := "`r`n`t<div id=""my-div"">`r`n`t`t<iframe id=""my-iframe"" src=""https://semlar.com/rivenprices/" . RegExReplace(CurrentRiven2, " ", "%20") . """ scrolling=""no"" sandbox=""allow-scripts allow-same-origin""></iframe>`r`n`t</div>`r`n" . WeaponHTML
return
;===============================================
LookupPrice:
	GuiControlGet, ItemName, ,ItemName
	ItemNameIN := ItemName
	if (InStr(ItemName, "riven",0)){
		ItemName := InStr(ItemName, "rifle", 0) ? "rifle_riven_mod_(veiled)" : ItemName
		ItemName := InStr(ItemName, "shotgun", 0) ? "shotgun_riven_mod_(veiled)" : ItemName
		ItemName := InStr(ItemName, "pistol", 0) ? "pistol_riven_mod_(veiled)" : ItemName
		ItemName := InStr(ItemName, "melee", 0) ? "melee_riven_mod_(veiled)" : ItemName
	}else
		ItemName := RegExMatch(ItemName, "i)prime$") ? ItemName . " set" : ItemName
	StringReplace, ItemName, ItemName, %A_Space%, _,All
	StringReplace, ItemName, ItemName, &, and,All
	StringLower, ItemName, ItemName
	UrlDownloadToFile, https://warframe.market/items/%ItemName%, PriceTemp.html
	FileRead, HTMLprices, PriceTemp.html
	FileDelete, PriceTemp.html
	FoundPos := Instr(HTMLprices,"""orders"": [")+12
	FoundPos2 := Instr(HTMLprices,"]",0,FoundPos)-1
	if (FoundPos<50)
		HTMLprices := "Item """ . ItemName . """ not found. Try Again."
	else{
		HTMLprices := RegExReplace(substr(HTMLprices, FoundPos, FoundPos2-FoundPos), """")
		HTMLpricesarray := StrSplit(HTMLprices,"}`, {")
		HTMLprices := "<p>Showing Results for <br>" . ItemName . "</p>`n<div class=""tab"">`n<button class=""tablinks"" onclick=""openTab('Buyers')"" id=""BuyersButton"">Buyers</button>`n<button class=""tablinks"" onclick=""openTab('Sellers')"" id=""SellersButton"">Sellers</button>`n</div>`n`n"
		HTMLpricesBuys2 := "", HTMLpricesBuys1 := "", HTMLpricesBuys := ""
		HTMLpricesSells2 := "", HTMLpricesSells1 := "", HTMLpricesSells := ""
		InGameName := "", PlatAmount := "", PlatHTML := "", OnlineStatus := "", AvatarImg := "", Platform := "", Region := "", OrderType := ""
		Loop % HTMLpricesarray.MaxIndex()
		{
			HTMLpricesCurrent := HTMLpricesarray[A_Index]
			StringReplace, HTMLpricesCurrent, HTMLpricesCurrent, }, ,All
			HTMLpricespieces := StrSplit(HTMLpricesCurrent,"`, ")
			Loop % HTMLpricespieces.MaxIndex(){
				HTMLpricesPiecesCurrent := HTMLpricespieces[A_Index]
				if (InStr(HTMLpricesPiecesCurrent,"ingame_name")){
					InGameName := substr(HTMLpricesPiecesCurrent,InStr(HTMLpricesPiecesCurrent,"ingame_name: ")+13)
					if (strLen(InGameName)>8){
						FoundPos := ceil(strLen(InGameName)/2), FoundPos := FoundPos>9 ? 9 : FoundPos
						DisplayGameName := substr(InGameName,1,FoundPos) . "-<br>" . substr(InGameName,FoundPos+1,FoundPos)
					}else
						DisplayGameName := InGameName
				}
				if (InStr(HTMLpricesPiecesCurrent,"platinum")){
					PlatAmount := substr(HTMLpricesPiecesCurrent,InStr(HTMLpricesPiecesCurrent,"platinum: ")+10)
					PlatHTML := PlatAmount . PlatIMG
				}
				if (InStr(HTMLpricesPiecesCurrent,"status")){
					OnlineStatus := substr(HTMLpricesPiecesCurrent,InStr(HTMLpricesPiecesCurrent,"status: ")+8)
					OnlineStatus := OnlineStatus="ingame" ? 	"Game" : OnlineStatus="online" ? "On" : OnlineStatus
				}
				if (InStr(HTMLpricesPiecesCurrent,"mod_rank"))
					Rank := substr(HTMLpricesPiecesCurrent,InStr(HTMLpricesPiecesCurrent,"mod_rank: ")+10)
				Region := InStr(HTMLpricesPiecesCurrent,"region") ? substr(HTMLpricesPiecesCurrent,InStr(HTMLpricesPiecesCurrent,"region: ")+8) : Region
				OrderType := InStr(HTMLpricesPiecesCurrent,"order_type") ? substr(HTMLpricesPiecesCurrent,InStr(HTMLpricesPiecesCurrent,"order_type: ")+12) : OrderType
				Platform := InStr(HTMLpricesPiecesCurrent,"platform") ? substr(HTMLpricesPiecesCurrent,InStr(HTMLpricesPiecesCurrent,"platform: ")+10) : Platform
				SortPrefix := OnlineStatus="Game" ? 2 : OnlineStatus="On" ? 1 : 0
			}
			if (OnlineStatus!="offline" && Region="en" && Platform="pc"){
				if (OrderType="buy"){
					HTMLpricesBuys2 := SortPrefix=2 ? HTMLpricesBuys2 . PlatAmount . "<tr><td>" . DisplayGameName . "</td><td>" . OnlineStatus . "</td><td>" . Rank . "</td><td>" . PlatHTML . "</td><td><button class=""msg"" onclick=""copyToClipboard('/w " . InGameName . " Hi! I want to sell: " . ItemNameIN . " for " . PlatAmount . " platinum. (warframe.market)')"">MSG</button></td></tr>`n" : HTMLpricesBuys2
					HTMLpricesBuys1 := SortPrefix=1 ? HTMLpricesBuys1 . PlatAmount . "<tr><td>" . DisplayGameName . "</td><td>" . OnlineStatus . "</td><td>" . Rank . "</td><td>" . PlatHTML . "</td><td><button class=""msg"" onclick=""copyToClipboard('/w " . InGameName . " Hi! I want to sell: " . ItemNameIN . " for " . PlatAmount . " platinum. (warframe.market)')"">MSG</button></td></tr>`n" : HTMLpricesBuys1
				}else{
					HTMLpricesSells2 := SortPrefix=2 ? HTMLpricesSells2 . PlatAmount . "<tr><td>" . DisplayGameName . "</td><td>" . OnlineStatus . "</td><td>" . Rank . "</td><td>" . PlatHTML . "</td><td><button class=""msg"" onclick=""copyToClipboard('/w " . InGameName . " Hi! I want to buy: " . ItemNameIN . " for " . PlatAmount . " platinum. (warframe.market)')"">MSG</button></td></tr>`n" : HTMLpricesSells2
					HTMLpricesSells1 := SortPrefix=1 ? HTMLpricesSells1 . PlatAmount . "<tr><td>" . DisplayGameName . "</td><td>" . OnlineStatus . "</td><td>" . Rank . "</td><td>" . PlatHTML . "</td><td><button class=""msg"" onclick=""copyToClipboard('/w " . InGameName . " Hi! I want to buy: " . ItemNameIN . " for " . PlatAmount . " platinum. (warframe.market)')"">MSG</button></td></tr>`n" : HTMLpricesSells1
				}
			}
		}
		if (StrLen(HTMLpricesBuys2)<10) && (StrLen(HTMLpricesBuys1)<10)
			HTMLpricesBuys := "<div id=""Buyers"" class=""tabcontent"">`n<table class=""BS""><tr><td>There are no Buyers</td></tr>`n</table>`n</div>`n`n"
		else{
			Sort, HTMLpricesBuys2, N R
			Sort, HTMLpricesBuys1, N R
			HTMLpricesBuys2 := RegExReplace(HTMLpricesBuys2,"[0-9]{1,6}<tr>", "<tr>")
			HTMLpricesBuys1 := RegExReplace(HTMLpricesBuys1,"[0-9]{1,6}<tr>", "<tr>")
			HTMLpricesBuys := "<div id=""Buyers"" class=""tabcontent"">`n<table class=""BS""><tr><th>Name</th><th>Status</th><th>Rank</th><th>Price</th><th>MSG</th></tr>" . HTMLpricesBuys2 . "`n`n" . HTMLpricesBuys1 . "`n`n</table>`n</div>`n`n"
		}
		if (StrLen(HTMLpricesSells2)<10) && (StrLen(HTMLpricesSells1)<10)
			HTMLpricesSells := "<div id=""Sellers"" class=""tabcontent"">`n<table class=""BS""><tr><td>There are no Sellers</td></tr>`n</table>`n</div>`n`n"
		else{
			Sort, HTMLpricesSells2, N
			Sort, HTMLpricesSells1, N
			HTMLpricesSells2 := RegExReplace(HTMLpricesSells2,"[0-9]{1,6}<tr>", "<tr>")
			HTMLpricesSells1 := RegExReplace(HTMLpricesSells1,"[0-9]{1,6}<tr>", "<tr>")
			HTMLpricesSells := "<div id=""Sellers"" class=""tabcontent"">`n<table class=""BS""><tr><th>Name</th><th>Status</th><th>Rank</th><th>Price</th><th>MSG</th></tr>" . HTMLpricesSells2 . "`n`n" . HTMLpricesSells1 . "`n`n</table>`n</div>`n`n"
		}
		HTMLprices := HTMLprices . HTMLpricesBuys . HTMLpricesSells
	}
	HTMLDisplay.document.getElementById("Prices").innerHTML := HTMLprices
	HTMLDisplay.document.getElementsByTagName("button")[3].click()
return
;===DEBUG======================================
~^+d::
	FileRead, HTML, html2.css
	FileRead, HTML2, javascript2.js
	Clipboard := "<!DOCTYPE html>`r`n<html>`r`n<head>`r`n<meta http-equiv=""X-UA-Compatible"" content=""IE=edge"">`r`n<meta charset=""utf-8"">`r`n`r`n<!--Color1:" . Color[1] . " - " . Color[5] . "-->`r`n<!--Color2:" . Color[2] . " - " . Color[6] . "-->`r`n<!--Color3:" . Color[3] . "-->`r`n<!--Color4:" . Color[4] . "-->`r`n<style>`r`n" . HTML . "`r`n</style>`r`n</head>`r`n<body>" . HTMLDisplay.document.getElementsByTagName("body")[0].innerHTML . "</body>`r`n<script>`r`n" . HTML2 . "`r`n</script>`r`n</html>"
	HTML := HTML2 := ""
	SoundBeep
return
;===LOOKUP PLAYER RELICS===========================
~^+l::
	if (WinActive("ahk_exe Warframe.x64.exe")){
		GoSub, GetPlayersRelics
		if (strLen(RelicsToSearch)>4)
		{
			;oVoice.Speak(RelicsToSearch)
			HTMLDisplay.document.getElementsByTagName("button")[1].click()
			ControlSetText, Edit1, %RelicsToSearch%, Warframe AIO
			CurrentTab := "Relics"
			GoSub, ManageMainTabs
			GoSub, LookupRelics
		}else
			oVoice.Speak("No Relics found")	
	}
return

~^l::
	if (WinActive("ahk_exe Warframe.x64.exe")){
		WinActivate, Warframe AIO
		CurrentTab := "Relics"
		GoSub, ManageMainTabs
		HTMLDisplay.document.getElementsByTagName("button")[1].click()
		ControlSetText, Edit1,, Warframe AIO
		ControlFocus, Edit1, Warframe AIO
	}
return

~^p::
	if (WinActive("ahk_exe Warframe.x64.exe")){
		WinActivate, Warframe AIO
		CurrentTab := "Prices"
		GoSub, ManageMainTabs
		HTMLDisplay.document.getElementsByTagName("button")[3].click()
		ControlSetText, Edit3,, Warframe AIO
		ControlFocus, Edit3, Warframe AIO
	}
return

~^+r::
	if (WinActive("ahk_exe Warframe.x64.exe")){
		WinActivate, Warframe AIO
		CurrentTab := "Rivens"
		GoSub, ManageMainTabs
		HTMLDisplay.document.getElementsByTagName("button")[2].click()
		ControlSetText, Edit2,, Warframe AIO
		ControlFocus, Edit2, Warframe AIO
	}
return