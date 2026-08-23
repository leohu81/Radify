#Requires AutoHotkey v2.0
#SingleInstance Force

#Include .\Lib\Gdip_All.ahk
#Include .\Radify.ahk

TraySetIcon('images\\radify0.ico',, true)

if !pToken := Gdip_Startup() {
    MsgBox('GDI+ failed to start. Please ensure GDI+ is available.',, 'Iconx')
    ExitApp()
}

OnExit((*) => (Radify.DisposeResources(), Gdip_Shutdown(pToken)))

; WhiteBubble skin: only plain object fields used by Radify.CreateMenu
Radify.skins.WhiteBubble := {
    itemGlowImage: 'None',
    menuOuterRimImage: 'None',
    menuBackgroundImage: 'MenuBack.png',
    itemBackgroundImage: 'ItemBack.png',
    centerBackgroundImage: 'CenterBack.png',
    centerImage: 'CenterImage.png',
    submenuIndicatorImage: 'SubmenuIndicator.png',
    itemSize: 80,
    radiusScale: 1.0,
    centerSize: 42,
    centerImageScale: 0.55,
    itemImageScale: 0.45,
    itemImageYRatio: 0.5,
    submenuIndicatorSize: 16,
    submenuIndicatorYRatio: 0.5,
    outerRingMargin: 2,
    outerRimWidth: 1,
    itemBackgroundImageOnCenter: true,
    itemBackgroundImageOnItems: true,
    menuClick: 'None',
    menuRightClick: 'None',
    centerClick: 'Close',
    centerRightClick: 'None',
    mirrorClickToRightClick: false,
    closeOnItemClick: false,
    closeOnItemRightClick: false,
    closeMenuBlock: false,
    enableItemText: false,
    enableGlow: false,
    enableTooltip: true,
    autoTooltip: true,
    autoCenterMouse: false,
    alwaysOnTop: true,
    activateOnShow: true,
    fillCenterHitZone: true,
    fillItemsHitZone: true,
    soundOnSelect: 'None',
    soundOnShow: 'None',
    soundOnClose: 'None',
    soundOnSubShow: 'None',
    soundOnSubClose: 'None',
    textFont: 'Segoe UI',
    textColor: '000000',
    textSize: 12,
    textFontOptions: '',
    textShadowColor: 'FFFFFF',
    textShadowOffset: 0,
    textBoxScale: 1.0,
    textYRatio: 0.75,
    textRendering: 5,
    smoothingMode: 4,
    interpolationMode: 7
}

Radify.defaults.skin := 'WhiteBubble'

; menus must be created with the current default skin available
edgeMenu := [
    [
        {image: 'CenterImage.png', click: 'Close'},
        {image: 'edge_close_tab.png', click: (*) => Send('^w')},
        {image: 'edge_new_tab.png', click: (*) => Send('^t')},
        {image: 'edge_duplicate_tab.png', click: (*) => DuplicateEdgeTab()}
    ]
]

pptMenu := [
    [
        {image: 'CenterImage.png', click: 'Close'},
        {image: 'ppt_copy_format.png', click: (*) => Send('^+c')},
        {image: 'ppt_paste_text.png', click: (*) => Send('^+v')}
    ]
]

systemMenu := [
    [
        {image: 'CenterImage.png', click: 'Close'},
        {image: 'sys_screenshot.png', click: (*) => Send('#+s')},
        {image: 'sys_play_pause.png', click: (*) => Send('{Media_Play_Pause}')},
        {image: 'sys_lock.png', click: (*) => Send('#l')},
        {image: 'sys_sleep.png', click: (*) => SleepAction()}
    ]
]

edgeOpts := {itemSize: 80, itemImageScale: 0.45, itemBackgroundImageOnItems: true, itemBackgroundImageOnCenter: true, enableItemText: false, enableGlow: false, alwaysOnTop: true, activateOnShow: true, fillCenterHitZone: true, fillItemsHitZone: true}
pptOpts := edgeOpts.Clone()
systemOpts := edgeOpts.Clone()

Radify.CreateMenu('edgeMenu', edgeMenu, edgeOpts)
Radify.CreateMenu('pptMenu', pptMenu, pptOpts)
Radify.CreateMenu('systemMenu', systemMenu, systemOpts)

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
