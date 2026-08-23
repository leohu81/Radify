#Requires AutoHotkey v2.0
#SingleInstance Force

InstallKeybdHook()
InstallMouseHook()

; 常駐，方便從工作列開 Key History
Persistent(true)

; F12 直接開啟 Key History
F12::KeyHistory()
