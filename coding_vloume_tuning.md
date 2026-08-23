<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# 我覺得半圓音量儀表板這個建議不錯，請給我一個完整的設計方案，我會交給專門coding的Agent來完成，包含需要做出哪些圖，架構設計及該注意的地方，請記得基於我的MyActionRing.ahk來給建議

建議把「音量」做成 System menu 內的一個入口，點擊後進入獨立的半圓音量儀表板；它不要被當成一般 Radify 的按鈕選單，而是一個短暫的互動控制模式。這樣最符合你目前 `MyActionsRing_final2.ahk` 的架構：System 功能集中在 `systemItems`、從 Edge/PPT 進入時保留返回邏輯、並由 `ShowMenuWithTimeout()` 管理 5 秒自動關閉。[^1]

## 目標互動

### 使用流程

1. 使用 `Ctrl + Shift + Alt + M` 開啟原本的 Edge、PPT 或 System menu。
2. 點擊新增的「音量」按鈕。
3. 原 menu 關閉，約 120 ms 後在同一個游標位置開啟 **Volume HUD**。
4. HUD 中央顯示目前音量，例如 `42%`；周圍是可拖動的上半圓刻度。
5. 在上半圓內移動滑鼠，音量即時調整。
6. 左鍵：確認當前音量並關閉。
7. 右鍵或 Esc：取消，還原進入音量模式前的音量並關閉。
8. 5 秒無操作：取消並還原原音量後關閉。

建議初版採用「**滑鼠進入控制環就立即調整，但不必按住左鍵**」；這符合 Radify 的快速呼叫、快速操作風格。若日後覺得容易誤碰，再加一個「按住左鍵才連續調整」的安全模式。

## 視覺設計

### 半圓配置

半圓在中央上方，控制範圍限定為 180°：

```text
          50%
       ─────●─────
    25%             75%

  0%      [ 42% ]      100%
          🔊
```

實際建議改成更接近儀表板的 layout：

```text
          50
      40        60
   30              70
 20                  80
10                    90

0        [ 42% ]        100
         🔊 / 靜音
```


### 幾何規格

以選單中心為原點：


| 元素 | 建議值 |
| :-- | --: |
| 控制弧半徑 | 150 px |
| 控制環可接受半徑 | 105–190 px |
| 弧線角度 | 左端 210°、頂端 270°、右端 330° |
| 音量範圍 | 0–100% |
| 刻度 | 每 5%，主要刻度每 10% |
| 中心圓直徑 | 84 px |
| 音量文字 | 24–30 px、粗體 |
| 更新頻率 | 20–33 ms |
| 音量吸附 | 0 / 25 / 50 / 75 / 100%，各約 ±2% |

這種設計比單純「上半圓」更容易用：弧線下緣的左右端不會太接近中心，並且保留中央區讓使用者停止調整、切換靜音或點擊確認。

### 狀態顏色

建議延續你目前的 `WhiteBubble` 乾淨外觀：


| 狀態 | 建議樣式 |
| :-- | :-- |
| 未調整的弧線 | 白色或淺灰、30–40% 透明 |
| 已填滿音量弧 | 主色，例如藍色 `#4AA3FF` |
| 目前音量指示點 | 白色外框 + 主色實心圓 |
| 50% / 100% 主刻度 | 稍大、較不透明 |
| 靜音 | 紅橘色或降低飽和度的灰色 |
| 取消 / 還原中 | 轉為淺灰，短暫顯示 `已還原` |

不要過度使用漸層、陰影或太多文字。Radify 的圓形選單已經很有視覺存在感，Volume HUD 最好是清楚、快速、可預測。

## 需要製作的圖

初版建議圖檔保持少量，主要由 GDI+ 畫弧、刻度、文字；這樣音量值與填充進度能即時更新。

### 必要圖檔

放在目前的 `images\` 資料夾：


| 檔名 | 尺寸建議 | 用途 |
| :-- | --: | :-- |
| `sys_volume.png` | 128×128 PNG 透明底 | System menu 的音量入口圖示 |
| `volume_speaker.png` | 128×128 PNG 透明底 | HUD 中央一般音量狀態 |
| `volume_muted.png` | 128×128 PNG 透明底 | HUD 中央靜音狀態 |
| `volume_back.png` | 128×128 PNG 透明底 | 可選：返回上一層或取消圖示 |

圖示風格應與既有 `sys_screenshot.png`、`sys_play_pause.png`、`sys_lock.png`、`sys_sleep.png` 一致：白色／淺灰線條、透明背景、簡潔圓角風格。你的目前 System menu 就是以這類 image item 組成。[^1]

### 不建議預先做成圖片

以下應由程式即時繪製：

- 0–100% 的填滿音量弧。
- 目前游標位置的指示點。
- 5% / 10% 刻度。
- 中央百分比。
- 靜音或取消提示。

若改成大量圖片，會需要為每個音量值準備不同圖層，難以維護，也無法平滑顯示。

## 架構設計

### 1. 不改既有主選單邏輯

保留現有：

```ahk
systemItems
systemMenu
systemFromAppMenu
ShowMenuWithTimeout()
CancelMenuTimeout()
OpenSystemMenu()
ReturnToPreviousMenu()
```

只新增音量入口與獨立音量控制模組。你現在的 `systemItems` 是一般 System menu 與 App 來源 System menu 共享的陣列，因此把入口加入這裡，兩種 System menu 都能使用。[^1]

入口概念：

```ahk
{
    image: 'sys_volume.png',
    click: (*) => OpenVolumeHud(),
    tooltip: '音量'
}
```

這個 item 不應像一般功能一樣單純送出按鍵後關閉；它應開啟控制模式。

### 2. 新增獨立狀態

建議加入：

```ahk
global gVolumeHud := {
    active: false,
    originalVolume: 0,
    originalMuted: false,
    currentVolume: 0,
    currentMuted: false,
    ownerMenuId: '',
    returnMenuId: '',
    hwnd: 0,
    gui: 0,
    hdc: 0,
    hbm: 0,
    obm: 0,
    graphics: 0,
    centerX: 0,
    centerY: 0,
    outerRadius: 150,
    innerRadius: 105,
    timer: 0,
    lastInputTick: 0
}
```

不要把音量狀態塞進 `gActiveMenu`。後者是你現有的 5 秒自動關閉管理用途；音量 HUD 的臨時狀態應分開，避免 timer、返回選單和還原音量互相干擾。你的腳本已使用 `gReturnMenu` 與 `gActiveMenu` 管理選單導航與自動關閉，因此再新增專用 state 最安全。[^1]

### 3. 音量 API 模組

請 coding Agent 建立一個獨立封裝，不要把 COM Core Audio 呼叫散落在 UI/滑鼠處理程式中：

```ahk
GetMasterVolume()         ; 回傳整數 0–100
SetMasterVolume(percent)  ; 接受並限制為 0–100
GetMasterMute()           ; 回傳 true / false
SetMasterMute(isMuted)
ToggleMasterMute()
```

目標 API 是 Windows Core Audio 的 `IAudioEndpointVolume`：

- `GetMasterVolumeLevelScalar`
- `SetMasterVolumeLevelScalar`
- `GetMute`
- `SetMute`

這比連續傳送 `{Volume_Up}` / `{Volume_Down}` 更適合 HUD：能精準設定絕對音量、不依賴目前的音量步進，且可讀取真實的系統音量。

**實作要求：**

- Core Audio 初始化與 COM 物件需妥善釋放。
- 音量值從 scalar $0.0 \text{ 到 } 1.0$ 轉換為整數 0–100。
- 對外只暴露 0–100；UI 不應知道 COM 細節。
- API 呼叫失敗時顯示短暫錯誤、關閉 HUD，但不破壞原本的 Radify menu。


### 4. HUD 繪製模組

獨立函式：

```ahk
CreateVolumeHud()
DestroyVolumeHud()
RenderVolumeHud()
DrawVolumeArc()
DrawVolumeTicks()
DrawVolumeIndicator()
DrawVolumeCenter()
ShowVolumeHudAt(mouseX, mouseY)
HideVolumeHud()
```

建議 **不強行把 HUD 做成標準 Radify menu**。原因是 Radify 的 item 是固定圓形 hitbox，而這個需求是連續弧形拖曳／hover 控制；獨立的透明 GDI+ GUI 更乾淨、不需要破壞 `Radify.ahk` 核心。Radify 本身也已用 GDI+ 生成 transparent/layered GUI，因此你現有專案已有相關基礎。[^2]

HUD GUI 建議：

```ahk
Gui('+AlwaysOnTop -Caption +ToolWindow +E0x80000 +E0x08000000')
```

不建議使用 `+E0x20` 滑鼠穿透，因為 HUD 需要接收 `WM_MOUSEMOVE`、左鍵與右鍵事件。

### 5. 輸入控制模組

新增：

```ahk
StartVolumeInteraction()
UpdateVolumeFromMouse()
CommitVolume()
CancelVolume()
CloseVolumeHud(restore := false)
```

建議用 `SetTimer(UpdateVolumeFromMouse, 20)` 讀取滑鼠位置，而不是只依賴 `WM_MOUSEMOVE`。Timer 可處理滑鼠停在 HUD 內、系統偶爾沒有送出 mouse-move 訊息等情況；Radify 自己的 hover/glow 也是以 `WM_MOUSEMOVE` 配合 20 ms Timer 更新。[^2]

## 數學與操作規則

### 位置映射

取滑鼠相對於 HUD 中心：

```ahk
dx := mouseX - gVolumeHud.centerX
dy := mouseY - gVolumeHud.centerY
distance := Sqrt(dx * dx + dy * dy)
angle := ATan2(dy, dx)
```

在 Windows 座標中，Y 軸向下，所以請 coding Agent 實際測試角度方向；不要只照搬一般數學座標系。

### 控制區

只在下列條件更新音量：

```text
innerRadius ≤ distance ≤ outerRadius
```

推薦：

```ahk
innerRadius := 105
outerRadius := 190
```

游標位於中心或弧線之外時：

- 保持目前音量。
- 不做任何改變。
- 指示點可淡化。
- 中心可顯示當前百分比。


### 弧線與音量映射

推薦使用由左下到右下的上弧：

```text
左端  = 0%
頂端  = 50%
右端  = 100%
```

實作上可定義：

```ahk
startAngle := 210
endAngle := 330
```

但這兩個角度在不同繪圖 API 或座標轉換裡方向可能不同，Agent 應將「畫弧角度」與「滑鼠角度」各自封裝、以實測校準。

音量計算概念：

```ahk
normalized := (mouseAngle - startAngle) / arcSpan
normalized := Max(0, Min(1, normalized))
volume := Round(normalized * 100)
```


### Snap 規則

避免音量數字在常用數值附近跳動：

```ahk
snapPoints := [0, 25, 50, 75, 100]
snapTolerance := 2
```

若計算結果與任一吸附點距離不超過 2，改成該值。

另外建議：

- 一般情況：1% 細調。
- 按住 Shift：5% 步進。
- 按住 Ctrl：1% 細調且暫時關閉 snap。
- 滑鼠滾輪：每格 ±2%，可作備用微調。
- 中央圓點擊：切換 mute，但保留調整前的非靜音音量。


## 與現有 timer 整合

### 開啟時

目前 `ShowMenuWithTimeout()` 會設定 5 秒自動關閉，`gActiveMenu` 保存當前 Radify menu。[^1]

`OpenVolumeHud()` 建議流程：

```text
1. 記錄 gActiveMenu 作為 owner / return menu。
2. 先讀取 originalVolume 與 originalMuted。
3. CancelMenuTimeout()，取消父選單的 5 秒 Timer。
4. Radify.Close(ownerMenuId)。
5. 等約 100–150 ms。
6. 在原游標位置顯示 Volume HUD。
7. 啟動 Volume HUD 自己的 5 秒 idle Timer。
```

不要繼續讓父選單的 `AutoCloseMenu()` 運作，不然它可能在 HUD 操作時關掉不相關選單或覆蓋狀態。

### Idle timer 行為

音量模式的 5 秒應視為「**最後一次有效互動後重新計時**」，比主 Radify menu 更符合調整器操作。

有效互動包括：

- 滑鼠在控制弧內移動並實際改變音量。
- 滾輪調整。
- 切換靜音。
- 左鍵確認。

5 秒後：

```ahk
CancelVolume()
```

即還原 `originalVolume`、`originalMuted`，再關閉 HUD。

這點和你原本一般 menu 的「顯示後固定 5 秒關閉」不同，但對音量調整會較安全；否則使用者正在拖動時可能突然被關閉。

### Esc 修正

你目前 Esc 是：

```ahk
Hotkey('Esc', (*) => WinClose(WinExist()))
```

它會直接關閉目前 Radify GUI。[^1]

Volume HUD 開始後，需讓 Esc 優先走：

```ahk
CancelVolume()
```

而不是直接 `WinClose()`；否則無法還原音量。完成後才回到你現有的 Radify Esc 行為。

## 需要避免的問題

- **不要**用 `Send('{Volume_Up}')` 連發來實作連續滑鼠控制；它不精準、OSD 會干擾，且調整速度因系統設定而異。
- **不要**每 20 ms 都重新建立 GUI、重新配置 bitmap、或重新初始化 Core Audio COM 物件；GUI、繪圖 surface 與 endpoint volume 介面應在 HUD 開啟時建立並重複使用。
- **不要**讓 Volume HUD 和父 Radify menu 的 hover/click handler 同時保持活動；先關閉／停用父 menu。
- **不要**把滑鼠在弧線外的移動換算成 0% 或 100%；必須有環形有效範圍，否則操作會很不穩。
- **不要**用透明但滑鼠穿透的 HUD；它會無法可靠收到 click、Esc／取消狀態與 mouse move。
- 多螢幕和 DPI：HUD 的中心、半徑、游標座標必須全部使用**螢幕座標**，並按該螢幕 DPI scale 繪製；Radify 本身有取得 DPI scale 與使用螢幕工作區定位的流程可作參考。[^2]
- 請避免讓 HUD 出現在螢幕邊緣被裁切；開啟時依 active monitor 的 work area 將 HUD 整體移回可視範圍。Radify 的 `ShowAt()` 已有類似的 monitor work-area 邊界限制邏輯。[^2]


## 驗收條件

交給 coding Agent 時，可用以下作為完成標準：

- System menu 出現可辨識的音量入口，且不影響原本截圖、播放/暫停、鎖定、睡眠、返回功能。[^1]
- Edge / PPT 進入 System menu 後也能開啟音量 HUD。
- HUD 開啟時，中心顯示與 Windows 主音量一致。
- 弧形控制能連續調整 0–100%，左端為 0%、頂端為 50%、右端為 100%。
- 靠近 0 / 25 / 50 / 75 / 100 時有穩定吸附。
- 點中心可 mute/unmute，且 unmute 恢復最近一次非零音量。
- 左鍵提交後，保留調整值並關閉。
- 右鍵、Esc、5 秒閒置後，回復開啟前音量與靜音狀態並關閉。
- 關閉時停止所有 Timer、釋放 GDI+/COM 物件，沒有殘留透明視窗或重複的 message handler。
- 連續開啟／取消 20 次不報錯、不累積 GUI、也不影響原本 5 秒自動關閉功能。
<span style="display:none">[^3][^4][^5][^6]</span>

<div align="center">⁂</div>

[^1]: MyActionsRing_final2.ahk

[^2]: Radify.ahk

[^3]: https://blog.csdn.net/gitblog_00364/article/details/141747653

[^4]: https://note.com/gentle_lupine925/n/nc09e99069b07

[^5]: https://slashmanmap.com/autohotkey-tutorial/

[^6]: https://ppl-ai-file-upload.s3.amazonaws.com/web/direct-files/attachments/images/49836594/a402e378-f5e6-4c8f-bd1a-dde4f3e31bee/image.jpg

