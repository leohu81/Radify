#Requires AutoHotkey v2

; ================================
; 純 AutoHotkey v2 範例 - 依應用程式切換選單
; 觸發按鍵：滑鼠中鍵 (MButton)
; ================================

edgeMenu := Menu()
edgeMenu.Title := "Edge 快捷"
edgeMenu.Add("關閉分頁", Edge_CloseTab)
edgeMenu.Add("新增分頁", Edge_NewTab)
edgeMenu.Add("複製分頁", Edge_DuplicateTab)

pptMenu := Menu()
pptMenu.Title := "PowerPoint 快捷"
pptMenu.Add("複製格式", PPT_CopyFormat)
pptMenu.Add("貼上文字", PPT_PasteText)

defaultMenu := Menu()
defaultMenu.Title := "系統快捷"
defaultMenu.Add("螢幕截圖", Sys_Screenshot)
defaultMenu.Add("播放/暫停", Sys_PlayPause)
defaultMenu.Add("鎖定", Sys_Lock)
defaultMenu.Add("進入睡眠", Sys_Sleep)

MButton::
{
    winExe := WinGetProcessName("A")
    if (winExe = "msedge.exe")
        edgeMenu.Show()
    else if (winExe = "POWERPNT.EXE")
        pptMenu.Show()
    else
        defaultMenu.Show()
}

Edge_CloseTab(*) => Send("^w")
Edge_NewTab(*) => Send("^t")
Edge_DuplicateTab(*)
{
    Send("^l")
    Sleep(100)
    Send("^c")
}

PPT_CopyFormat(*) => Send("^+c")
PPT_PasteText(*) => Send("^+v")

Sys_Screenshot(*)
{
    Send("#+s")
}

Sys_PlayPause(*)
{
    Send("{Media_Play_Pause}")
}

Sys_Lock(*)
{
    Send("#l")
}

Sys_Sleep(*)
{
    ; 送出睡眠指令，若公司政策或驅動不允許，可能需要替換為其他方式
    DllCall("PowrProf\SetSuspendState", "Int", 0, "Int", 0, "Int", 0)
}
