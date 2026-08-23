#Requires AutoHotkey v2.0
#SingleInstance Force

#Include .\Lib\Gdip_All.ahk
#Include .\Radify.ahk

TraySetIcon('images\radify0.ico',, true)

if !pToken := Gdip_Startup() {
    MsgBox('GDI+ failed to start. Please ensure you have GDI+ on your system.',, 'Iconx')
    ExitApp()
}

OnExit((*) => (Radify.DisposeResources(), Gdip_Shutdown(pToken)))

; 用你目前的預設 skin，不在腳本裡動 skins 結構
; Radify.defaults.skin 保持原樣（例如 AstroGold）

; ========= Edge =========
edgeMenu := [
    [
        {image: 'edge_close_tab.png',   click: (*) => Send('^w'), tooltip: '關閉分頁'},
        {image: 'edge_new_tab.png',     click: (*) => Send('^t'), tooltip: '新增分頁'},
        {image: 'edge_duplicate_tab.png', click: (*) => DuplicateEdgeTab(), tooltip: '複製分頁'},
    ]
]

edgeOpts := {
    itemSize: 80,
    ; 讓中心區域點擊就關閉整個 menu 樹
    centerClick: "Close",
    ; 也可以讓 menu 背景點擊就關閉（可選）
    menuClick: "CloseMenu"
}

; ========= PowerPoint =========
pptMenu := [
    [
        {image: 'ppt_copy_format.png', click: (*) => Send('^+c'), tooltip: '複製格式'},
        {image: 'ppt_paste_text.png',  click: (*) => Send('^+v'), tooltip: '貼上文字'},
    ]
]

pptOpts  := edgeOpts.Clone()

; ========= System (其他程式) =========
systemMenu := [
    [
        {image: 'sys_screenshot.png',  click: (*) => Send('#+s'), tooltip: '螢幕截圖'},
        {image: 'sys_play_pause.png',  click: (*) => Send('{Media_Play_Pause}'), tooltip: '播放/暫停'},
        {image: 'sys_lock.png',        click: (*) => Send('#l'), tooltip: '鎖定'},
        {image: 'sys_sleep.png',       click: (*) => SleepAction(), tooltip: '進入睡眠'},
    ]
]

systemOpts := edgeOpts.Clone()

; ========= 建立選單 =========
Radify.CreateMenu('edgeMenu',   edgeMenu,   edgeOpts)
Radify.CreateMenu('pptMenu',    pptMenu,    pptOpts)
Radify.CreateMenu('systemMenu', systemMenu, systemOpts)

; ========= 中鍵觸發 =========  
LWin::
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
A_TrayMenu.Add('Show Edge Menu',   (*) => Radify.Show('edgeMenu'))
A_TrayMenu.Add('Show PPT Menu',    (*) => Radify.Show('pptMenu'))
A_TrayMenu.Add('Show System Menu', (*) => Radify.Show('systemMenu'))
A_TrayMenu.Add('Reload', (*) => Reload())
A_TrayMenu.Add('Exit',   (*) => ExitApp())

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
    try DllCall('PowrProf\SetSuspendState', 'Int', 0, 'Int', 0, 'Int', 0)
}
