#Requires AutoHotkey v2.0
#SingleInstance Force

#Include .\Lib\Gdip_All.ahk
#Include .\Radify.ahk

TraySetIcon('images\\radify0.ico',, true)

if !pToken := Gdip_Startup()
{
    MsgBox('GDI+ failed to start. Please ensure GDI+ is available.',, 'Iconx')
    ExitApp()
}

OnExit((*) => (Radify.DisposeResources(), Gdip_Shutdown(pToken)))

edgeMenu := [
    [
        {text: '關閉分頁', click: (*) => Send('^w')},
        {text: '新增分頁', click: (*) => Send('^t')},
        {text: '複製分頁', click: (*) => DuplicateEdgeTab()}
    ]
]

pptMenu := [
    [
        {text: '複製格式', click: (*) => Send('^+c')},
        {text: '貼上文字', click: (*) => Send('^+v')}
    ]
]

systemMenu := [
    [
        {text: '螢幕截圖', click: (*) => Send('#+s')},
        {text: '播放/暫停', click: (*) => Send('{Media_Play_Pause}')},
        {text: '鎖定', click: (*) => Send('#l')},
        {text: '進入睡眠', click: (*) => SleepAction()}
    ]
]

; 依照附圖風格：淺色、圓角感、簡潔、留白大、圖示為主
edgeOpts   := {itemSize: 72}
pptOpts    := {itemSize: 72}
systemOpts := {itemSize: 72}
mainOpts   := {itemSize: 82}

Radify.CreateMenu('edgeMenu', edgeMenu, edgeOpts)
Radify.CreateMenu('pptMenu', pptMenu, pptOpts)
Radify.CreateMenu('systemMenu', systemMenu, systemOpts)

; 主選單：只放分類入口
mainMenu := [
    [
        {text: 'Edge', submenu: edgeMenu, textSize: 12},
        {text: 'PPT', submenu: pptMenu, textSize: 12},
        {text: 'System', submenu: systemMenu, textSize: 12}
    ]
]
Radify.CreateMenu('mainMenu', mainMenu, mainOpts)

; 嘗試套用較接近附圖的視覺設定（若你的 Radify 版本支援，會生效；不支援則忽略）
try Radify.SetSkin('Light')
try Radify.SetDirection('Clockwise')

MButton::
{
    winExe := WinGetProcessName('A')
    if (winExe = 'msedge.exe')
        Radify.Show('edgeMenu')
    else if (winExe = 'POWERPNT.EXE')
        Radify.Show('pptMenu')
    else
        Radify.Show('systemMenu')
}

HotIfWinExist('RadifyGui_0_0 ahk_class AutoHotkeyGUI')
Hotkey('Esc', (*) => WinClose(WinExist()))
HotIfWinExist()

A_TrayMenu.Delete()
A_TrayMenu.Add('Show Edge Menu', (*) => Radify.Show('edgeMenu'))
A_TrayMenu.Add('Show PPT Menu', (*) => Radify.Show('pptMenu'))
A_TrayMenu.Add('Show System Menu', (*) => Radify.Show('systemMenu'))
A_TrayMenu.Add('Reload', (*) => Reload())
A_TrayMenu.Add('Exit', (*) => ExitApp())

DuplicateEdgeTab()
{
    Send('^l')
    Sleep(100)
    Send('^c')
    Sleep(80)
    Send('^t')
    Sleep(80)
    Send('^v')
    Sleep(80)
    Send('{Enter}')
}

SleepAction()
{
    try DllCall('PowrProf\\SetSuspendState', 'Int', 0, 'Int', 0, 'Int', 0)
}
