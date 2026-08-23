#Requires AutoHotkey v2.0
#SingleInstance Force

#Include .\Lib\Gdip_All.ahk
#Include .\Radify.ahk

TraySetIcon('images\radify0.ico',, true)

if !pToken := Gdip_Startup() {
    MsgBox('GDI+ failed to start. Please ensure GDI+ is available.',, 'Iconx')
    ExitApp()
}

OnExit(CleanUp)

global gReturnMenu := ''
Radify.defaults.skin := 'WhiteBubble'

; Shared System actions. Maintain this list only.
systemItems := [
    {image: 'sys_screenshot.png', click: (*) => Send('#+s'), tooltip: '螢幕截圖'},
    {image: 'sys_play_pause.png', click: (*) => Send('{Media_Play_Pause}'), tooltip: '播放/暫停'},
    {image: 'sys_lock.png', click: (*) => Send('#l'), tooltip: '鎖定'},
    {image: 'sys_sleep.png', click: (*) => SleepAction(), tooltip: '進入睡眠'}
]

; Direct System menu: four items.
systemMenu := [systemItems]

; System menu reached from Edge/PPT: five items.
systemFromAppItems := systemItems.Clone()
systemFromAppItems.InsertAt(1, {
    image: 'back.png',
    click: (*) => ReturnToPreviousMenu(),
    tooltip: '回上一層'
})
systemFromAppMenu := [systemFromAppItems]

; A larger radius prevents five 80px items from touching.
systemOpts := {
    itemSize: 60,
    radiusScale: 1.20,
    outerRingMargin: 12,
    centerClick: 'Close',
    menuClick: 'CloseMenu',
    fillCenterHitZone: true,
    fillItemsHitZone: true,
    enableItemText: true,
    enableTooltip: true,
    autoTooltip: true
}

Radify.CreateMenu('systemMenu', systemMenu, systemOpts)
Radify.CreateMenu('systemFromAppMenu', systemFromAppMenu, systemOpts)

edgeMenu := [
    [
        {image: 'edge_close_tab.png', click: (*) => Send('^w'), tooltip: '關閉分頁'},
        {image: 'edge_new_tab.png', click: (*) => Send('^t'), tooltip: '新增分頁'},
        {image: 'edge_duplicate_tab.png', click: (*) => DuplicateEdgeTab(), tooltip: '複製分頁'},
        {
            image: 'settings-app.png',
            click: (*) => OpenSystemMenu('edgeMenu'),
            tooltip: 'System Menu',
            itemImageScale: 0.40
        }
    ]
]

edgeOpts := {
    itemSize: 60,
    radiusScale: 1.20,
    outerRingMargin: 8,
    centerClick: 'Close',
    menuClick: 'CloseMenu',
    fillCenterHitZone: true,
    fillItemsHitZone: true,
    enableItemText: false,
    enableTooltip: true,
    autoTooltip: false
}

Radify.CreateMenu('edgeMenu', edgeMenu, edgeOpts)

pptMenu := [
    [
        {image: 'ppt_copy_format.png', click: (*) => Send('^+c'), tooltip: '複製格式'},
        {image: 'ppt_paste_text.png', click: (*) => Send('^+v'), tooltip: '貼上文字'},
        {
            image: 'settings-app.png',
            click: (*) => OpenSystemMenu('pptMenu'),
            tooltip: 'System Menu',
            itemImageScale: 0.40
        }
    ]
]

pptOpts := {
    itemSize: 60,
    radiusScale: 1.20,
    outerRingMargin: 8,
    centerClick: 'Close',
    menuClick: 'CloseMenu',
    fillCenterHitZone: true,
    fillItemsHitZone: true,
    enableItemText: false,
    enableTooltip: true,
    autoTooltip: false
}

Radify.CreateMenu('pptMenu', pptMenu, pptOpts)

^+!m::
{
    global gReturnMenu
    gReturnMenu := ''

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

OpenSystemMenu(parentMenuId)
{
    global gReturnMenu
    gReturnMenu := parentMenuId
    Radify.Close(parentMenuId)
    SetTimer(ShowSystemFromAppMenu, -120)
}

ShowSystemFromAppMenu()
{
    Radify.Show('systemFromAppMenu')
}

ReturnToPreviousMenu()
{
    global gReturnMenu
    Radify.Close('systemFromAppMenu')

    if (gReturnMenu != '') {
        menuToRestore := gReturnMenu
        gReturnMenu := ''
        SetTimer((*) => Radify.Show(menuToRestore), -120)
    }
}

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

A_TrayMenu.Delete()
A_TrayMenu.Add('Show Edge Menu', (*) => Radify.Show('edgeMenu'))
A_TrayMenu.Add('Show PPT Menu', (*) => Radify.Show('pptMenu'))
A_TrayMenu.Add('Show System Menu', (*) => Radify.Show('systemMenu'))
A_TrayMenu.Add('Reload', (*) => Reload())
A_TrayMenu.Add('Exit', (*) => ExitApp())

CleanUp(*)
{
    Radify.DisposeResources()
    Gdip_Shutdown(pToken)
}
