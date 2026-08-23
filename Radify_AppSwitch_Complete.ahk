#Requires AutoHotkey v2

; ================================
; Radify 範例 - 依應用程式切換環形選單
; 觸發按鍵：滑鼠中鍵 (MButton)
; ================================

; 載入 Radify 核心類別（請從 Radify 專案下載 RadifyClass.ahk）
; GitHub: https://github.com/XMCQCX/RadifyClass-RadifySkinEditor
#Include RadifyClass.ahk

; 建立 Radify 實例
radify := Radify()

; ================================
; 設定選單配置
; ================================

; Edge 瀏覽器選單
edgeConfig := {
    skin: "Default",  ; 使用預設主題
    items: [
        ; 格式：{label: "文字", icon: "圖示路徑或內建圖示", action: "Radify 模板或 AHK 程式碼"}
        {label: "關閉分頁", icon: "", action: 'Send("^w")'},
        {label: "新增分頁", icon: "", action: 'Send("^t")'},
        {label: "複製分頁", icon: "", action: 'Send("^l") Sleep(100) Send("^c")'}
    ]
}

; PowerPoint 選單
powerpointConfig := {
    skin: "Default",
    items: [
        {label: "複製格式", icon: "", action: 'Send("^+c")'},
        {label: "貼上文字", icon: "", action: 'Send("^+v")'}
    ]
}

; 預設選單（其他應用程式）
defaultConfig := {
    skin: "Default",
    items: [
        {label: "螢幕截圖", icon: "", action: 'Run("ms-screenclip:")'},
        {label: "播放/暫停", icon: "", action: 'SendMediaKey("Play_Pause")'},
        {label: "鎖定", icon: "", action: 'Run("rundll32.exe user32.dll,LockWorkStation")'},
        {label: "進入睡眠", icon: "", action: 'Run("rundll32.exe powrprof.dll,SetSuspendState 0,0,0")'}
    ]
}

; ================================
; 載入各應用程式的選單配置
; ================================

; 載入 Edge 選單
radify.LoadConfig(edgeConfig)
edgeMenuId := radify.CreateMenu()

; 載入 PowerPoint 選單
radify.LoadConfig(powerpointConfig)
powerpointMenuId := radify.CreateMenu()

; 載入預設選單
radify.LoadConfig(defaultConfig)
defaultMenuId := radify.CreateMenu()

; ================================
; 設定觸發按鍵（滑鼠中鍵）
; ================================

MButton::
{
    ; 取得目前前景視窗的執行檔名稱
    winExe := WinGetProcessName("A")

    ; 根據執行檔名稱選擇要顯示的選單
    if (winExe = "msedge.exe")
    {
        radify.ShowMenu(edgeMenuId)
    }
    else if (winExe = "POWERPNT.EXE")
    {
        radify.ShowMenu(powerpointMenuId)
    }
    else
    {
        radify.ShowMenu(defaultMenuId)
    }
}

; ================================
; 提示
; ================================

; 1. 請確保 RadifyClass.ahk 在同一資料夾
; 2. 可以從這裡下載 Radify: https://github.com/XMCQCX/RadifyClass-RadifySkinEditor
; 3. 修改圖示：在 icon 欄位填入圖示檔案路徑（支援 .ico, .png）
; 4. 自訂更多動作：參考 Radify 內建模板文件
