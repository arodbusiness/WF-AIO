CheckFiles(){
	FileSettings := A_ScriptDir . "\WF-AIO.ini"
	if (!FileExist(FileSettings)){
		file := FileOpen(FileSettings, "w")
		file.Write("[Main]`r`nX=0`r`nY=0`r`nW=338`r`nH=500`r`nFollowingChat=0`r`nSpeech=1")
		file.close
	}

	Dirs := "Pages|Images|Images\Icons|Images\Rewards|Images\RelicRewards"
	Array := StrSplit(Dirs, "|")
	Loop % Array.MaxIndex(){
		Dir := A_ScriptDir . "\" . Array[A_Index]
		if (!FileExist(Dir))
			FileCreateDir, %Dir%
	}

	Files := "html.css|javascript.js|Speak.ahk|wf.ico|Images\blank.png|Images\Warframe_Logo.png|Images\Warframe_Text.png"
	Array := StrSplit(Files, "|")
	Loop % Array.MaxIndex(){
		File := A_ScriptDir . "\" . Array[A_Index]
		if (!FileExist(File)){
			MsgBox, "%File%" does not exist.
			ExitApp
		}
	}
}


AssignImgHTML(FilePath, URL, ByWidth, Dimension){
	FilePath2 := DownloadAndResize(FilePath, URL, ByWidth, Dimension)
	if (ByWidth)
		HTMLIMG := "<img src=""" . FilePath2 . """ width=""" . Dimension . "px"" height=""auto"">"
	else
		HTMLIMG := "<img src=""" . FilePath2 . """ width=""auto"" height=""" . Dimension . "px"">"
	return HTMLIMG
}

ChooseRandomColor(MinC, MaxC, HighC){
	Random, Red, MinC, MaxC
	Random, Green, MinC, MaxC
	Random, Blue, MinC, MaxC
	Random, Pick, 1, 6
	if (Red+Green+Blue<MaxC*2.75){
		Red := (Pick=1) ? Red*0.4+MaxC*0.66 : (Pick = 4 || Pick = 5) ? Red*0.2+MaxC*0.33 : Red
		Green := (Pick=2) ? Green*0.4+MaxC*0.66 : (Pick = 4 || Pick = 6) ? Green*0.2+MaxC*0.33 : Green
		Blue := (Pick=3) ? Blue*0.4+MaxC*0.66 : (Pick = 5 || Pick = 6) ? Blue*0.2+MaxC*0.33 : Blue
	}else if (Red+Green+Blue>MaxC*0.75){
		Red := (Pick=1 || Pick = 4 || Pick = 5) ? MinC : Red
		Green := (Pick=2 || Pick = 4 || Pick = 6) ? MinC : Green
		Blue := (Pick=3 || Pick = 5 || Pick = 6) ? MinC : Blue
	}
	
	Red2 := Red+HighC>=255 ? 255 : Red+HighC, Red3 := round(Red/255,2)
	Green2 := Green+HighC>=255 ? 255 : Green+HighC, Green3 := round(Green/255,2)
	Blue2 := Blue+HighC>=255 ? 255 : Blue+HighC, Blue3 := round(Blue/255,2)
	Colors := []
	Colors[1] := FHex(Red) . FHex(Green) . FHex(Blue)
	Colors[2] := FHex(Red2) . FHex(Green2) . FHex(Blue2)
	Colors[3] := Red3 . "," . Green3 . "," . Blue3
	Colors[4] := "0xFF" . Colors[1]
	Colors[5] := Red . "," . Green . "," . Blue
	Colors[6] := Red2 . "," . Green2 . "," . Blue2
	return Colors
}
DownloadPageGetImage(item){
	FilePath := A_ScriptDir . "/Pages/" . item . ".html"
	URL := "http://warframe.wikia.com/wiki/" . item
	if (!FileExist(FilePath))
		UrlDownloadToFile, %URL%, %FilePath%
	FileRead, TempFile, %FilePath%
	FoundPos := InStr(TempFile, "portable-infobox")
	FoundPos := FoundPos=0 ? InStr(TempFile, "floatright") : FoundPos
	FoundPos2 := InStr(TempFile, "<`/a>", 0, FoundPos)
	if (FoundPos>0 && FoundPos2>0){
		TempFile := substr(TempFile, FoundPos, FoundPos2-FoundPos)
		FoundPos2 := RegexMatch(TempFile, "O)src=""https://(.+?)\.png",Match)
		if (FoundPos2>0){
			URL := "https://" . Match[1] . ".png"
		}
	}
	return URL
}

DownloadAndResize(FilePath, URL, ByWidth, Dimension){
	if (!FileExist(FilePath))
		UrlDownloadToFile, %URL%, %FilePath%
	FilePath2 := RegExReplace(FilePath, "^(.+?)\.(png|jpg|jpeg|gif)","$1_" . Dimension . ".$2")	
	if (!FileExist(FilePath2)){
		pBitmap := Gdip_CreateBitmapFromFile(FilePath)
		Gdip_GetDimensions(pBitmap, w, h)
		Ratio := round(w/h,2)
		if (ByWidth){
			w2 := Dimension
			h2 := w2/Ratio
		}else{
			h2 := Dimension
			w2 := h2*Ratio
		}
		pBitmap2 := Gdip_CreateBitmap(w2, h2)
		G := Gdip_GraphicsFromImage(pBitmap2)
		Gdip_SetSmoothingMode(G, 2), Gdip_SetInterpolationMode(G, 7)
		Gdip_DrawImage(G, pBitmap, 0, 0, w2, h2, 0, 0, w, h)
		Gdip_SaveBitmapToFile(pBitmap2, Filepath2)
		Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), Gdip_DisposeImage(pBitmap2)
	}
	return FilePath2
}
DownloadAndMatrix(FilePath, URL, Color:=""){
	if (!FileExist(FilePath))
		UrlDownloadToFile, %URL%, %FilePath%
	FilePath2 := RegExReplace(FilePath, "^(.+?)\.(png|jpg|jpeg|gif)","$1_Colored.$2")	
	Color := Color="" ? "1,1,1" : Color, Color := StrSplit(Color, ",")
	Red := Color[1], Green := Color[2], Blue := Color[3]
	Matrix=
	(
	1|0|0|0|0|
	0|1|0|0|0|
	0|0|1|0|0|
	0|0|0|1|0|
	%Red% | %Green%  | %Blue% |0|1
	)
	pBitmap := Gdip_CreateBitmapFromFile(FilePath)
	Gdip_GetDimensions(pBitmap, w, h)
	pBitmap2 := Gdip_CreateBitmap(w, h)
	G := Gdip_GraphicsFromImage(pBitmap2)
	Gdip_DrawImage(G, pBitmap, 0, 0, w, h,,,,, Matrix)
	Gdip_SaveBitmapToFile(pBitmap2, Filepath2), Gdip_DeleteGraphics(G)
	Gdip_DisposeImage(pBitmap), Gdip_DisposeImage(pBitmap2)
	return FilePath2
}

MakeSplash(ByRef Variable, Color := "1.0,1.0,1.0", Logo := "", Text := ""){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable
	pBitmap := Gdip_CreateBitmap(PosW, PosH)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap), SetImage(hwnd, hBitmap)
	
	Text := Text="" ? A_ScriptDir . "\Images\Warframe_Text.png" : Text
	Color := StrSplit(Color, ",")
	Red := Color[1], Green := Color[2], Blue := Color[3]
	pBitmap := Gdip_CreateBitmapFromFile(Text), Gdip_GetDimensions(pBitmap, TextW, TextH)
	
	pBitmap3 := Gdip_CreateBitmap(PosW, PosH)
	G := Gdip_GraphicsFromImage(pBitmap3)
	Gdip_SetInterpolationMode(G,7)
	Gdip_SetSmoothingMode(G,4)
	

	LogoW2 := 0
	Strength := 0.75, Matrix := 1
	if (Logo="" || InStr(Logo,"Warframe_Logo")){
		Logo := A_ScriptDir . "\Images\Warframe_Logo.png"
		Matrix= 
		(
		%Strength%|0|0|0|0|
		0|%Strength%|0|0|0|
		0|0|%Strength%|0|0|
		0|0|0|1|0|
		%Red% | %Green%  | %Blue% |0|1
		)
		pBitmap2 := Gdip_CreateBitmapFromFile(Logo), Gdip_GetDimensions(pBitmap2, LogoW, LogoH)
		Ratio := LogoW/LogoH
		LogoW2 := PosW*0.25
		LogoH2 := LogoW2/Ratio
		LogoX := 0
		LogoY := PosH-LogoH2-4
	}else{
		pBitmap2 := Gdip_CreateBitmapFromFile(Logo), Gdip_GetDimensions(pBitmap2, LogoW, LogoH)
		Ratio := LogoW/LogoH
		if (LogoH>PosH){
			LogoH2 := PosH
			LogoW2 := LogoH2*Ratio
		}else{
			LogoW2 := PosW*0.33
			LogoH2 := LogoW2/Ratio
		}
		LogoX := 0
		LogoY := PosH/2-LogoH2/2+5
	}
	
	Ratio := TextW/TextH
	overlap := 16
	TextW2 := PosW-LogoW2+overlap
	TextH2 := TextW2/Ratio
	TextX := LogoX+LogoW2-overlap
	TextY := PosH-TextH2
	Gdip_DrawImage(G, pBitmap, TextX, TextY, TextW2, TextH2, 0, 0, TextW, TextH, Matrix)
	Gdip_DrawImage(G, pBitmap2, LogoX, LogoY, LogoW2, LogoH2, 0, 0, LogoW, LogoH, Matrix)
	
	FilePath := A_ScriptDir . "\Images\Warframe_Splash.png"
	Gdip_SaveBitmapToFile(pBitmap3, FilePath)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap3), SetImage(hwnd, hBitmap)
	Gdip_DeleteGraphics(G)
	Gdip_DisposeImage(pBitmap), Gdip_DisposeImage(pBitmap2), Gdip_DisposeImage(pBitmap3)
	DeleteObject(hBitmap)
	return LogoW2
}

MakeMoon(Dimension:=20, InnerR:=0.55, OuterR:=0.95){
	Foreground := "0xFFE0EAF2"
	PosW := PosH := Dimension
	BorderSize := 2
	Filepath := A_ScriptDir . "\Images\Icons\Moon_" . Dimension . ".png"
	if (!FileExist(FilePath)){
		pBitmap := Gdip_CreateBitmap(PosW, PosH)
		G := Gdip_GraphicsFromImage(pBitmap)
		Gdip_SetSmoothingMode(G, 4)
		pPen:=Gdip_CreatePen(Foreground, PosW/32)
		
		Sizer := 0.5
		rinc := 0.02
		CurrentR := InnerR
		While (CurrentR-OuterR<0){
			x1 := PosW*0.75
			y1 := -2+PosH-(1-Sizer)*PosH*0.5

			x2 := x1-PosW*Sizer*CurrentR
			y2 := -2+PosH/2+(Sizer)*PosH*CurrentR

			x3 := x2
			y3 := -2+PosH/2-(Sizer)*PosH*CurrentR

			x4 := x1
			y4 := -2+(1-Sizer)*PosH*0.5

			Gdip_DrawBezier(G, pPen, x1, y1, x2, y2, x3, y3, x4, y4)
			CurrentR := CurrentR+rinc
		}

		Gdip_DeletePen(pPen)
		Gdip_DeleteGraphics(G)
		Gdip_SaveBitmapToFile(pBitmap, FilePath)
		Gdip_DisposeImage(pBitmap)
	}
	return FilePath
}

MakeSun(Dimension:=20, Circle:=0.4, Angle:=60, MinRayLength:=0.24, MaxRayLength:=0.4, MaxRayLength2:=0.45){
	Foreground := "0xFFFFC116"
	PosW := PosH := Dimension
	Filepath := A_ScriptDir . "\Images\Icons\Sun_" . Dimension . ".png"
	if (!FileExist(FilePath)){
		pBitmap := Gdip_CreateBitmap(PosW, PosH)
		w := floor(PosW*Circle), h := w
		x := PosW/2-w/2, y := x
		G := Gdip_GraphicsFromImage(pBitmap)
		Gdip_SetSmoothingMode(G, 3)
		pBrush := Gdip_BrushCreateSolid(Foreground)
		pPen:=Gdip_CreatePenFromBrush(pBrush, PosW/16)
		
		Gdip_FillPie(G, pBrush, x, y, w, h, 0, 360)
		
		r1 := 0.05*PosW, r2 := x - r1
		points := r1 "," 0.5*PosH "|" r2 "," 0.5*PosH
		
		pi := 3.141592653589793
		Loop, 2
		{
			AnglesCheck := ""
			Angles := []
			CurrentAngle := A_Index=1 ? 0 : Angle/2
			CurrentAngle := CurrentAngle*pi/180
			RayLength := A_Index=1 ? MaxRayLength : MaxRayLength2
			While (CurrentAngle<2*pi)	{
				CurrentAngle := CurrentAngle + Angle*pi/180
				Angles.push(CurrentAngle)
				AnglesCheck := AnglesCheck . "`n" . CurrentAngle
			}

			Loop % Angles.MaxIndex(){
				xcord1 := PosW/2+sin(Angles[A_Index])*PosW*MinRayLength
				ycord1 := PosH/2+cos(Angles[A_Index])*PosH*MinRayLength
				xcord2 := PosW/2+sin(Angles[A_Index])*PosW*RayLength
				ycord2 := PosH/2+cos(Angles[A_Index])*PosH*RayLength
				points := xcord1 "," ycord1 "|" xcord2 "," ycord2
				Gdip_DrawLines(G, pPen, points)
			}
		}
		Gdip_ImageRotateFlip(pBitmap,2)
		Gdip_DeletePen(pPen)
		Gdip_DeleteGraphics(G)
		Gdip_SaveBitmapToFile(pBitmap, FilePath)
		Gdip_DisposeImage(pBitmap)
	}
	return FilePath
}

MakeCog(ByRef Variable, Foreground:="0xFFFF00FF", Angle:=45, InnerR:=0.14, OuterR:=0.28, MaxRayLength:=0.38){
	PosW2 := PosH2 := 128
	Filepath := A_ScriptDir . "\Images\Icons\Cog_" . PosW2 . ".png"
	pBitmap := Gdip_CreateBitmap(PosW2, PosH2)
	G := Gdip_GraphicsFromImage(pBitmap)
	pi := 3.141592653589793
	MicroAngle := 2
	pPen := Gdip_CreatePen(Foreground, PosW2/8) 
	pPen2 := Gdip_CreatePen(Foreground, 2)
	Loop, 2
	{
		PenRef := A_Index=1 ? pPen : pPen2
		Angles := []
		CurrentAngle := 0*pi/180
		Angle := A_Index=1 ? Angle : MicroAngle
		RayLength := A_Index=1 ? MaxRayLength : OuterR
		While (CurrentAngle<2*pi)	{
			CurrentAngle := CurrentAngle + Angle*pi/180
			Angles.push(CurrentAngle)
		}

		Loop % Angles.MaxIndex(){
			xcord1 := (PosW2/2+sin(Angles[A_Index])*PosW2*InnerR)
			ycord1 := (PosH2/2+cos(Angles[A_Index])*PosH2*InnerR)
			xcord2 := (PosW2/2+sin(Angles[A_Index])*PosW2*RayLength)
			ycord2 := (PosH2/2+cos(Angles[A_Index])*PosH2*RayLength)
			points := xcord1 "," ycord1 "|" xcord2 "," ycord2
			Gdip_DrawLines(G, PenRef, points)
		}
	}
	Gdip_DeleteGraphics(G)
	Gdip_SaveBitmapToFile(pBitmap, FilePath)
	
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable
	Filepath := A_ScriptDir . "\Images\Icons\Cog_" . PosW . ".png"

	pBitmap2 := Gdip_CreateBitmap(PosW, PosH)
	G := Gdip_GraphicsFromImage(pBitmap2)
	
	pPen3 := Gdip_CreatePen(Foreground, 2)
	Gdip_DrawRectangle(G, pPen3, 0, 0, PosW, PosH)
	Gdip_SetSmoothingMode(G, 3)
	Gdip_SetInterpolationMode(G,7)
	Gdip_DrawImage(G, pBitmap, 0, 0, PosW, PosH, 0, 0, PosW2, PosH2)
	Gdip_SaveBitmapToFile(pBitmap2, FilePath)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap2), SetImage(hwnd, hBitmap)

	
	Gdip_DeletePen(pPen), Gdip_DeletePen(pPen2), Gdip_DeletePen(pPen3)
	Gdip_DisposeImage(pBitmap)
}

MakeArrow(ByRef Variable, Foreground:="0xFFFF00FF",flip:=0){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable 
	pBitmap := Gdip_CreateBitmap(PosW, PosH),G := Gdip_GraphicsFromImage(pBitmap)
	pPen:=Gdip_CreatePen(Foreground, 1), pPen2:=Gdip_CreatePen(Foreground, 2)
	Gdip_DrawRectangle(G, pPen2, 0, 0, PosW, PosH)
	points:= PosW/2 ",0|" 0.9* PosW "," 0.4* PosH "|" 0.6* PosW "," 0.4* PosH "|" 0.6* PosW "," PosH "|" 0.33* PosW "," PosH 
	points:= points "|" 0.35* PosW "," 0.4* PosH "|" 0.35* PosW "," 0.4* PosH "|" 0.1* PosW "," 0.4* PosH "|" PosW/2 ",0"
	pBrushFront := Gdip_BrushCreateSolid(Foreground), pPath := Gdip_CreatePath(0)
	Gdip_AddPathPolygon(pPath,points) 
	Gdip_FillPath(G,pBrushFront, pPath) 
	Gdip_ImageRotateFlip(pBitmap,flip)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap), SetImage(hwnd, hBitmap)
	Gdip_DeleteBrush(pBrushFront), Gdip_DeletePen(pPen), Gdip_DeletePen(pPen2), Gdip_DeletePath(pPath), Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
}

MakeE(ByRef Variable, Foreground:="0xFFFF00FF",BorderSize:=2){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable 
	pBitmap := Gdip_CreateBitmap(PosW, PosH)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap), SetImage(hwnd, hBitmap)
	
	pBitmap := Gdip_CreateBitmap(PosW, PosH), G := Gdip_GraphicsFromImage(pBitmap)
	pPen:=Gdip_CreatePen(Foreground, 1), pPen2:=Gdip_CreatePen(Foreground, BorderSize)
	Gdip_DrawRectangle(G, pPen2, 0, 0, PosW, PosH)
	TextOptions := "x0p y4p s80p Center c" . substr(Foreground,3) . " r5 Bold"
	Gdip_TextToGraphics(G, "E", TextOptions, "Arial", Posw, Posh)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap), SetImage(hwnd, hBitmap)
	GuiControl, MoveDraw, Variable
	Gdip_DeletePen(pPen), Gdip_DeletePen(pPen2), Gdip_DeletePath(pPath), Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
}

MakeMove(ByRef Variable, Foreground:="0xFFFF00FF",BorderSize:=2){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable 
	pBitmap := Gdip_CreateBitmap(PosW, PosH)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap), SetImage(hwnd, hBitmap)
	G := Gdip_GraphicsFromImage(pBitmap)
	pPen:=Gdip_CreatePen(Foreground, 1), pPen2:=Gdip_CreatePen(Foreground, BorderSize)
	Gdip_DrawRectangle(G, pPen2, 0, 0, PosW, PosH)
	points:= PosW*0.5 ",0|" 0.75* PosW "," 0.2* PosH "|" 0.54* PosW "," 0.2* PosH "|" 0.54* PosW "," 0.5* PosH "|" 0.45* PosW "," 0.5* PosH 
	points:= points "|" 0.45* PosW "," 0.5* PosH "|" 0.45* PosW "," 0.2* PosH "|" 0.2* PosW "," 0.2* PosH "|" PosW*0.5 ",0"
	pBrushFront := Gdip_BrushCreateSolid(Foreground)
	Loop,4
	{
		pPath := Gdip_CreatePath(0)
		Gdip_AddPathPolygon(pPath,points) 
		Gdip_FillPath(G,pBrushFront, pPath) 
		Gdip_ImageRotateFlip(pBitmap,A_Index)
	}
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap), SetImage(hwnd, hBitmap)
	GuiControl, MoveDraw, Variable
	Gdip_DeleteBrush(pBrushFront), Gdip_DeletePen(pPen), Gdip_DeletePen(pPen2), Gdip_DeletePath(pPath), Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
}

MakeMinimize(ByRef Variable, Foreground:="0xFFFF00FF"){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable 
	pBitmap := Gdip_CreateBitmap(PosW, PosH)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap), SetImage(hwnd, hBitmap)
	G := Gdip_GraphicsFromImage(pBitmap)
	pPen:=Gdip_CreatePen(Foreground, 4), pPen2:=Gdip_CreatePen(Foreground, 2)
	Gdip_DrawRectangle(G, pPen2, 0, 0, PosW, PosH)
	points := 0.2*PosW "," 0.66*PosH "|" 0.8*PosW "," 0.66*PosH
	Gdip_DrawLines(G, pPen, points)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap), SetImage(hwnd, hBitmap)
	Gdip_DeletePen(pPen),Gdip_DeletePen(pPen2),Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
}

MakeChat(ByRef Variable, Foreground:="0xFFFF00FF", BorderSize:=2){
	GuiControlGet, Pos, Pos, Variable
	GuiControlGet, hwnd, hwnd, Variable 
	pBitmap := Gdip_CreateBitmap(PosW, PosH)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap), SetImage(hwnd, hBitmap)
	G := Gdip_GraphicsFromImage(pBitmap)
	pPen:=Gdip_CreatePen(Foreground, 4), pPen2:=Gdip_CreatePen(Foreground, BorderSize)
	Gdip_DrawRectangle(G, pPen2, 0, 0, PosW, PosH)
	points := 0.77*PosW "," 0.15*PosH "|" 0.77*PosW "," 0.85*PosH
	Gdip_DrawLines(G, pPen, points)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap), SetImage(hwnd, hBitmap)
	GuiControl, MoveDraw, Variable
	Gdip_DeletePen(pPen),Gdip_DeletePen(pPen2),Gdip_DeleteGraphics(G), Gdip_DisposeImage(pBitmap), DeleteObject(hBitmap)
}

Display(WB,html_str) {
	FileDelete, %A_Temp%\*.DELETEME.html
	i=0
	while % FileExist(f:=A_Temp "\" A_TickCount A_NowUTC "-tmp" i ".DELETEME.html")
		i+=1
	FileAppend,%html_str%,%f%
	WB.Navigate("file://" . f)
}

FHex( int, pad=0 ) { ; Function by [VxE]. Formats an integer (decimals are truncated) as hex.
	Static hx := "0123456789ABCDEF"
	If !( 0 < int |= 0 )
		Return !int ? "00" : "-" FHex( -int, pad )
	s := 1 + Floor( Ln( int ) / Ln( 16 ) )
	h := SubStr( "0x0000000000000000", 1, pad := pad < s ? s + 2 : pad < 16 ? pad + 2 : 18 )
	u := A_IsUnicode = 1
	Loop % s
		NumPut( *( &hx + ( ( int & 15 ) << u ) ), h, pad - A_Index << u, "UChar" ), int >>= 4
	h := StrReplace(h,"0x")
	h := StrLen(h)<2 ? "0" . h : h
	Return h
}


WM_MOUSEMOVE(wParam,lParam){
	WinGetPos, pos_x, pos_y, pos_w, pos_h, Warframe AIO
	;pos_w := pos_w-16
	;pos_h := pos_h-39
	IniWrite, %pos_x%, %FileSettings%, Main, X
	IniWrite, %pos_y%, %FileSettings%, Main, Y

	Global hCurs
	MouseGetPos,,,,ctrl
	;Only change over certain controls, use Windows Spy to find them.
	If ctrl in Static7,Static8,Static9,Static11,Static12,Static13,Static17
		DllCall("SetCursor","UInt",hCurs)
	Return
}

WM_LBUTTONDOWN(){
	if (MoveNow=1){
		PostMessage, 0xA1, 2,,,Warframe AIO ; movable borderless window 
	}
	Return
}

WM_LBUTTONUP(wParam:="",lParam:=""){
	if (MoveNow=1){
		;MoveNow=0
	}
	Global hCurs
	MouseGetPos,,,,ctrl
	;Only change over certain controls, use Windows Spy to find them.
	If ctrl in Static7,Static8,Static9,Static11,Static12,Static13,Static17
		DllCall("SetCursor","UInt",hCurs)
	Return
}