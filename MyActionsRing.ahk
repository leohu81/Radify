#Requires AutoHotkey v2.0
#SingleInstance Force

#Include .\Lib\Gdip_All.ahk

if !pToken := Gdip_Startup() {
    MsgBox('GDI+ failed to start. Please ensure GDI+ is available.',, 'Iconx')
    ExitApp()
}
#Include .\radify_pie_menu.ahk

OnExit(CleanUp)

hRadifyIcon := 'HICON:*' LoadPicture('images\radify1.ico', 'w32', &imgType)
TraySetIcon(hRadifyIcon,, true)

Radify.defaults.skin := 'WhiteBubble'

global gReturnMenu := ''
global gActiveMenu := ''

global gCloseMenuTimer := -3000
global gFirstRingOffset := 30

systemItems := [
    {image: 'sys_screenshot.png', click: (*) => (CancelMenuTimeout(), Send('#+s')), tooltip: '畫面截圖'},
    {image: 'sys_play_pause.png', click: (*) => (CancelMenuTimeout(), Send('{Media_Play_Pause}')), tooltip: '播放/暫停'},
    {image: 'vol_up.png', click: (*) => (SetTimer(CloseActiveRadifyMenu, gCloseMenuTimer), Send('{Volume_Up}')), closeOnItemClick: false, tooltip: '增加音量'},
    {image: 'vol_down.png', click: (*) => (SetTimer(CloseActiveRadifyMenu, gCloseMenuTimer), Send('{Volume_Down}')), closeOnItemClick: false, tooltip: '降低音量'},
    {image: 'sys_lock.png', click: (*) => (CancelMenuTimeout(), DllCall('LockWorkStation')), tooltip: '鎖定'},
    {image: 'sys_sleep.png', click: (*) => (CancelMenuTimeout(), SleepAction()), tooltip: '睡眠'}
]

systemMenu := [systemItems]

systemFromAppItems := systemItems.Clone()
systemFromAppItems.InsertAt(1, {
    image: 'back.png',
    click: (*) => ReturnToPreviousMenu(),
     tooltip: '回上一層'
})
systemFromAppMenu := [systemFromAppItems]

systemOpts := {
    itemSize: 70,
    firstRingOffset: gFirstRingOffset,
    centerClick: 'Close',
    centerRightClick: 'Close',
    menuClick: 'CloseMenu',
    menuRightClick: 'CloseMenu',
    fillCenterHitZone: true,
    fillItemsHitZone: true,
    enableItemText: false,
    enableTooltip: true,
    autoTooltip: false,
    enableDarkening: true,
    closeOnItemClick: true,
    closeOnItemRightClick: true
}

systemFromAppOpts := {
    itemSize: 60,
    firstRingOffset: gFirstRingOffset,
    centerClick: 'Close',
    centerRightClick: 'Close',
    menuClick: 'CloseMenu',
    menuRightClick: 'CloseMenu',
    fillCenterHitZone: true,
    fillItemsHitZone: true,
    enableItemText: false,
    enableTooltip: true,
    autoTooltip: false,
    enableDarkening: true,
    closeOnItemClick: true,
    closeOnItemRightClick: true
}

Radify.CreateMenu('systemMenu', systemMenu, systemOpts)
Radify.CreateMenu('systemFromAppMenu', systemFromAppMenu, systemFromAppOpts)

edgeMenu := [
    [
        {image: 'edge_close_tab.png', click: (*) => (CancelMenuTimeout(), Send('^w')), tooltip: '關閉分頁'},
        {image: 'edge_new_tab.png', click: (*) => (CancelMenuTimeout(), Send('^t')), tooltip: '新增分頁'},
        {image: 'edge_duplicate_tab.png', click: (*) => (CancelMenuTimeout(), DuplicateEdgeTab()), tooltip: '複製分頁'},
        {image: 'refresh.png', click: (*) => (CancelMenuTimeout(), Send('^r')), tooltip: '重新整理'},
        {image: 'settings-app.png', click: (*) => (CancelMenuTimeout(), OpenSystemMenu('edgeMenu')), tooltip: 'System Menu', itemImageScale: 0.40}
    ]
]

edgeOpts := {
    itemSize: 70,
    firstRingOffset: gFirstRingOffset,
    centerClick: 'Close',
    centerRightClick: 'Close',
    menuClick: 'CloseMenu',
    menuRightClick: 'CloseMenu',
    fillCenterHitZone: true,
    fillItemsHitZone: true,
    enableItemText: false,
    enableTooltip: true,
    autoTooltip: false,
    enableDarkening: true,
    closeOnItemClick: true,
    closeOnItemRightClick: true
}

Radify.CreateMenu('edgeMenu', edgeMenu, edgeOpts)

pptMenu := [
    [
        {image: 'ppt_copy_format.png', click: (*) => (CancelMenuTimeout(), Send('^+c')), tooltip: '複製格式'},
        {image: 'ppt_paste_text.png', click: (*) => (CancelMenuTimeout(), Send('^+v')), tooltip: '貼上格式'},
        {image: 'settings-app.png', click: (*) => (CancelMenuTimeout(), OpenSystemMenu('pptMenu')), tooltip: 'System Menu', itemImageScale: 0.40}
    ]
]

pptOpts := {
    itemSize: 70,
    firstRingOffset: gFirstRingOffset,
    centerClick: 'Close',
    centerRightClick: 'Close',
    menuClick: 'CloseMenu',
    menuRightClick: 'CloseMenu',
    fillCenterHitZone: true,
    fillItemsHitZone: true,
    enableItemText: false,
    enableTooltip: true,
    autoTooltip: false,
    enableDarkening: true,
    closeOnItemClick: true,
    closeOnItemRightClick: true
}

Radify.CreateMenu('pptMenu', pptMenu, pptOpts)

fileExplorerMenu := [
    [
        {image: 'settings-app.png', click: (*) => (CancelMenuTimeout(), OpenSystemMenu('fileExplorerMenu')), tooltip: '進入system menu'},
        {image: 'folder_new.png', click: (*) => (CancelMenuTimeout(), CreateNewFolder()), tooltip: '開新資料夾'},
        {image: 'cmd_white.png', click: (*) => (CancelMenuTimeout(), OpenCommandPrompt()), tooltip: '打開命令列'}
    ]
]

fileExplorerOpts := {
    itemSize: 70,
    firstRingOffset: gFirstRingOffset,
    centerClick: 'Close',
    centerRightClick: 'Close',
    menuClick: 'CloseMenu',
    menuRightClick: 'CloseMenu',
    fillCenterHitZone: true,
    fillItemsHitZone: true,
    enableItemText: false,
    enableTooltip: true,
    autoTooltip: false,
    enableDarkening: true,
    closeOnItemClick: true,
    closeOnItemRightClick: true
}

Radify.CreateMenu('fileExplorerMenu', fileExplorerMenu, fileExplorerOpts)

^+!m::
{
    global gReturnMenu
    gReturnMenu := ''

    winExe := WinGetProcessName('A')
    if (winExe = 'msedge.exe')
        ShowMenuWithTimeout('edgeMenu')
    else if (winExe = 'POWERPNT.EXE')
        ShowMenuWithTimeout('pptMenu')
    else if (winExe = 'explorer.exe')
        ShowMenuWithTimeout('fileExplorerMenu')
    else
        ShowMenuWithTimeout('systemMenu')
}

HotIfWinExist('RadifyGui_0_0 ahk_class AutoHotkeyGUI')
Hotkey('Esc', (*) => CloseCurrentMenu())
HotIfWinExist()

OpenSystemMenu(parentMenuId)
{
    global gReturnMenu
    CancelMenuTimeout()
    gReturnMenu := parentMenuId
    Radify.Close(parentMenuId)
    SetTimer(ShowSystemFromAppMenu, -120)
}

ShowSystemFromAppMenu()
{
    ShowMenuWithTimeout('systemFromAppMenu')
}

ReturnToPreviousMenu()
{
    global gReturnMenu
    CancelMenuTimeout()
    Radify.Close('systemFromAppMenu')

    if (gReturnMenu != '') {
        menuToRestore := gReturnMenu
        gReturnMenu := ''
        SetTimer((*) => ShowMenuWithTimeout(menuToRestore), -120)
    }
}

CloseCurrentMenu()
{
    global gActiveMenu
    CancelMenuTimeout()
    if (gActiveMenu != '')
        Radify.Close(gActiveMenu)
}

ShowMenuWithTimeout(menuId)
{
    global gActiveMenu

    ; Stop only the old one-shot timer. This function never calls itself.
    SetTimer(CloseActiveRadifyMenu, 0)
    gActiveMenu := menuId
    Radify.Show(menuId)
    SetTimer(CloseActiveRadifyMenu, gCloseMenuTimer)
}

CloseActiveRadifyMenu()
{
    global gActiveMenu

    menuId := gActiveMenu
    gActiveMenu := ''

    if (menuId != '')
        Radify.Close(menuId)
}

CancelMenuTimeout()
{
    global gActiveMenu
    SetTimer(CloseActiveRadifyMenu, 0)
    gActiveMenu := ''
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

CreateNewFolder()
{
    Send('{Shift}{F10}')
    Sleep(150)
    Send('n')
    Sleep(100)
    Send('{Enter}')
}

OpenCommandPrompt()
{
    Send('^{F4}')
    Sleep(100)
    Send('cmd')
    Sleep(50)
    Send('{Enter}')
}

A_TrayMenu.Delete()
A_TrayMenu.Add('Show Edge Menu', (*) => ShowMenuWithTimeout('edgeMenu'))
A_TrayMenu.Add('Show PPT Menu', (*) => ShowMenuWithTimeout('pptMenu'))
A_TrayMenu.Add('Show System Menu', (*) => ShowMenuWithTimeout('systemMenu'))
A_TrayMenu.Add('Show File Explorer Menu', (*) => ShowMenuWithTimeout('fileExplorerMenu'))
A_TrayMenu.Add('Reload', (*) => Reload())
A_TrayMenu.Add('Exit', (*) => ExitApp())

CleanUp(*)
{
    SetTimer(CloseActiveRadifyMenu, 0)
    Radify.DisposeResources()
    Gdip_Shutdown(pToken)
}

