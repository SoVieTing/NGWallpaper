;~ Desc:	下载美国国家地理每日图片并设为桌面
;~ Author:	劇終
;~ Lib:		Gdip.ahk
FileEncoding, UTF-8
;~ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━SetWorkingDir
SetWorkingDir, %A_ScriptDir%
FileCreateDir, Wallpapers
SetWorkingDir, %A_ScriptDir%\Wallpapers
;~ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━命令行参数手动下载
if 1=/m ;手动下载指定地址参数 /m ;将需要下载图片那天的网址粘贴进inputbox
{
InputBox, url_file, National Geographic_Photo of the Day, 请输入需要下载图片那天的网址:
	if url_file=
		ExitApp
}
else url_file=http://www.nationalgeographic.com/photography/photo-of-the-day
;~ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━下载网页,5次失败则退出
Loop
	{
		t+=1
		URLDownloadToFile, %url_file%, temp
		If Errorlevel=0
		{
			; MsgBox, 下载成功
			Break
		}
		Else If t>=5
			{
				; MsgBox 获取地址5次失败
				FileDelete temp
				ExitApp
			}
	}
/*
;~ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━[老版本的]匹配关键字,得到数组
FileRead url_pic,temp
need=<div\s*class="download_link"><a\s*href="(.*)">Download\s*Wallpaper\s*\((\d*)\s\w\s(\d*)\spixels\)</a></div>\r*\s*<div\s*id="caption">\r*\s*<p\s*class="publication_time">(\w+)\s(\d+),\s(\d{4})</p>\r*\s*<h2>(.*)</h2>
RegExMatch(url_pic,need,match)

if match1= ;如果上面匹配不出图片地址,则匹配小图
{
;~ MsgBox, 图片受版权限制,不允许下载大图
need=<div\s*class="primary_photo">\r*\s*.*\s*<img src="(.+)"\s*width="(\d+)"\s*height="(\d+)"\s*alt=".+"\s*/>[^*]*<div\s*id="caption">\r*\s*<p\s*class="publication_time">(\w+)\s(\d+),\s(\d{4})</p>\r*\s*<h2>(.*)</h2>
RegExMatch(url_pic,need,match)
}

;Loop
;{
;	i+=1
;	MsgBox, % match%i%
;}
*/
;~ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━匹配关键字,得到数组
FileRead url_pic,temp

Pic_Link=<meta property="og:image" content="(.+?)"/>
RegExMatch(url_pic, Pic_Link, Pic_Link)
Pic_Link:=Pic_Link1

Pic_Title=<title>(.+?)(\s\|.+)??</title>
RegExMatch(url_pic, Pic_Title, Pic_Title)
Pic_Title:=Pic_Title1

Pic_Width=<meta property="og:image:width" content="(\d+)"/>
RegExMatch(url_pic, Pic_Width, Pic_Width)
Pic_Width:=Pic_Width1

Pic_Height=<meta property="og:image:height" content="(\d+)"/>
RegExMatch(url_pic, Pic_Height, Pic_Height)
Pic_Height:=Pic_Height1

Pic_Date=<meta property="article:published_time" content="(.+?)"/>
RegExMatch(url_pic, Pic_Date, Pic_Date_org)
StringReplace, Pic_Date_org1, Pic_Date_org1, -, ., All
; -----------------------------------------格式化日期为数字形式：如果不含".", 为英文格式的日期：Wed Aug 24 00:04:32 EDT 2016
if !InStr(Pic_Date_org1, ".")
	{
		Pic_Date=<meta property="article:published_time" content=".+?\s(.+?)\s(\d+)\s.+?\s.+?\s(\d+)"/>
		RegExMatch(url_pic, Pic_Date, Pic_Date_org)

		Pic_Date_month:=Month_Word2Num(Pic_Date_org1)

		if StrLen(Pic_Date_org2)=1 ;如果日期为1位数则补足两位
			Pic_Date_org2:= "0" Pic_Date_org2
		Pic_Date_date:=Pic_Date_org2

		Pic_Date_year:=Pic_Date_org3

		Pic_Date:=Pic_Date_year . "." . Pic_Date_month . "." . Pic_Date_date
	}
else Pic_Date:=Pic_Date_org1

Month_Word2Num(str){ ;格式化月份单词为两位数字的函数
	Static Months := "_Jan01_January01_Feb02_February02_Mar03_March03_Apr04_April04_May05_Jun06_June06_Jul07_July07_Aug08_August08_Sep09_September09_Oct10_October10_Nov11_November11_Dec12_December12_"
	Return RegExReplace(Months, "i).*_" str "(\d+)_.*", "$1")
}

PicName := Pic_Date . "_" . Pic_Title . "_" . Pic_Width . "×" . Pic_Height . ".jpg" ;文件名形成
; -----------------------------------------debug
; MsgBox, % Pic_Link
; MsgBox, % Pic_Title
; MsgBox, % Pic_Width
; MsgBox, % Pic_Height
; MsgBox, % Pic_Date
; MsgBox, % PicName
; ExitApp
;~ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━如果已存在同名文件,则退出
If FileExist(PicName)
	{
		;~ MsgBox, 已经下载过了
		FileDelete temp
		ExitApp
	}
;~ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━否则开始下载图片,5次失败则退出
Loop
	{
		t+=1
		URLDownloadToFile, %Pic_Link%, %PicName%
		If Errorlevel=0
			{
				FileDelete temp
				Break
			}
		Else If t>=5
			{
				; MsgBox 获取图片5次失败
				FileDelete temp
				ExitApp
			}
	}

/*
;~ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━有界面的确定
MsgBox, 35, National Geographic_Photo of the Day, 是否立即设为壁纸？`n`nY ： 设置壁纸`nN ： 不设只看`nC ： 立刻消失, 9
IfMsgBox, Yes
	{
		;~ Run, ..\..\..\..\IrfanView\i_view32.exe %PicName% /wall=2 /killmesoftly
		ChangeWallPaper(PicName)
	}
IfMsgBox, No
	{
		;~ Run, ..\..\..\..\IrfanView\i_view32.exe %PicName%
		Run, %PicName%
	}
IfMsgBox, Cancel
	{
		ExitApp
	}
IfMsgBox, Timeout ;超时同默认Yes
	{
		;~ Run, ..\..\..\..\IrfanView\i_view32.exe %PicName% /wall=2 /killmesoftly
		ChangeWallPaper(PicName)
	}
 */

;~ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━托盘提示的确定
ChangeWallPaper(PicName)
TrayTip, NGWallpaper, Done！, 9, 1
Sleep, 9000

;~ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━退出脚本
ExitApp

;~ ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━functions
;~ Author: by tmplinshi
;~ Style: 0=平铺 1=居中 2=拉伸
;~ 需要库Gdip.ahk
ChangeWallPaper(FileName, Style = 2)
	{
		SplitPath, FileName, name,, ext
		If ext != bmp
			{
				ConvertImage(FileName, A_Temp "\~wallpaper.bmp")
				FileName := A_Temp "\~wallpaper.bmp"
			}

		TileWallpaper := !Style ? 1 : 0
		RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, TileWallpaper, %TileWallpaper%
		RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, WallpaperStyle, %Style%
		RegWrite, REG_SZ, HKEY_CURRENT_USER, Control Panel\Desktop, Wallpaper, %FileName%
		DllCall("SystemParametersInfo", uint, 0x0014, uint, 0x0000, str, fileName, uint, 0x0002)
	}

ConvertImage(sInput, sOutput)
	{
		Gdip_Startup()
		pBitmap := Gdip_CreateBitmapFromFile(sInput)
		Gdip_SaveBitmapToFile(pBitmap, sOutput)
		Gdip_DisposeImage(pBitmap)
		Gdip_Shutdown(pToken)
	}
