#NoEnv
#SingleInstance Force
#HotkeyInterval 1000
#MaxHotkeysPerInterval 500
#InstallKeybdHook
#InstallMouseHook

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global Variables
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

message := ""
message_time := 0
message_interval := 100

emacs_apps := ["ahk_exe msrdc.exe", "ahk_exe emacs.exe", "ahk_exe code.exe", "ahk_exe nvim-qt.exe", "ahk_exe alacritty.exe", "ahk_exe mintty.exe"]
emacs_c := 0
emacs_x := 0

mdx := 0
mdy := 0
mouse_offset := 32

wdx := 0
wdy := 0
wdw := 0
wdh := 0
win_offset := 32

corner_offset := 32
corner_timer := 300
corner_lt := 0
corner_rt := 0
corner_lb := 0
corner_rb := 0

komorebi_prefix := 0

scroll_timer := 100
scroll_flag := 0
old_x := 0
old_y := 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

removeToolTip() {
    ToolTip
}

updateToolTip() {
    global message
    global message_time
    global message_interval
    if (message_time < 0) {
        ToolTip % message
        message_time := message_time + message_interval
        SetTimer updateToolTip, % message_interval
    } else {
        ToolTip
    }
}

createToolTip(msg, t) {
    global message := msg
    global message_time := t
    updateToolTip()
}

isEmacs() {
    global emacs_apps
    WinGet curr_app, ProcessName
    for i, app in emacs_apps {
        if WinActive(app) {
            return 1
        }
    }
    return 0
}

moveScroll() {
    global scroll_flag
    global old_x
    global old_y
    CoordMode Mouse, Screen
    MouseGetPos x, y
    if (old_x != 0) or (old_y != 0) {
        MouseMove old_x, old_y
	if (x > old_x) {
            diff_x := (x - old_x) / 10
            Send +{WheelUp %diff_x%}
        } else if (x < old_x) {
            diff_x := (old_x - x) / 10
            Send +{WheelDown %diff_x%}
        }
	if (y > old_y) {
            diff_y := (y - old_y) / 10
            Send {WheelUp %diff_y%}
        } else if (y < old_y) {
            diff_y := (old_y - y) / 10
            Send {WheelDown %diff_y%}
        }
    }
}

hotCorners() {
    global corner_offset
    global corner_lt
    ;global corner_rt
    ;global corner_lb
    ;golbal corner_rb
    CoordMode Mouse, Screen
    MouseGetPos x, y
    if (x < corner_offset) and (y < corner_offset) {
        corner_lt++
        if (corner_lt = 2) {
            Send #{Tab}
        } else if (corner_lt > 3) {
            corner_lt--
        }
    } else {
        corner_lt := 0
    }
    SetTimer hotCorners, % corner_timer
}

komorebic(cmd) {
    global komorebi_prefix
    komorebi_prefix := 0
    removeToolTip()
    RunWait "komorebic.exe" %cmd%, , "Hide"
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Auto Hot Key
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#s::Suspend

#r::
    ToolTip Reload
    Sleep 1000
    ToolTip
    Reload
    return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Invert Mouse
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

*$WheelUp::WheelDown
*$WheelDown::WheelUp
XButton1::Send #{Tab}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Emacs
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

CapsLock::Ctrl
Ctrl::CapsLock

*Esc::`
*`::
    if !isEmacs() {
        Send {Blind}{Shift up}
        emacs_c := 0
        emacs_x := 0
    }
    komorebi_prefix := 0
    Send {Esc}
    return

#If !isEmacs()
    +Space::Send {vk15sc138}

    *^b::Send {Left}
    *^f::Send {Right}
    *^p::Send {Up}
    *^n::Send {Down}

    *^a::Send {Home}
    *^e::Send {End}
    *!v::Send {PgUp}
    *^v::Send {PgDn}

    *!b::Send ^{Left}
    *!f::Send ^{Right}

    !w::Send ^c
    ^w::Send ^x
    ^y::Send ^v
    ^k::
        Send {Shift down}
        Send {End}
        Send {Shift up}
        Send ^x
        return

    *^Space::
        Send {Blind}{Shift up}
        Send {Blind}{Shift down}
        return

    $^s::
        if (emacs_x) {
            Send ^s
        } else {
            Send ^f
            if WinActive("ahk_exe firefox.exe") {
                Send ^g
            } else {
                Send {F3}
            }
        }
        return
    ^r::
        Send ^f
        if WinActive("ahk_exe firefox.exe") {
            Send ^+g
        } else {
            Send +{F3}
        }
        return

    ^c::
        if (emacs_c) {
            emacs_c := 0
            removeToolTip()
            Send ^c
        } else if (emacs_x) {
            emacs_x := 0
            removeToolTip()
            Send !{F4}
        } else {
            emacs_c := 1
            createToolTip("Ctrl-C", -3000)
        }
        return
    ^x::
        emacs_x := 1
        createToolTip("Ctrl-X", -3000)
        return
    $k::
        if (emacs_x) {
            emacs_x := 0
            removeToolTip()
            Send ^{F4}
        } else {
            Send k
        }
        return
#If

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Window Snap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
~*LButton::
    WinGetPos ox, oy, ow, oh, A
    return

~*LButton Up::
    nid := WinActive("A")
    if (oid != nid) {
        oid := nid
        return
    }

    WinGetClass class, A
    if (class != "MozillaDialogClass" and class != "mpv") {
        return
    }

    CoordMode Mouse, Screen
    MouseGetPos x, y
    SysGet count, MonitorCount
    Loop %count% {
        SysGet WorkArea, MonitorWorkArea, %A_Index%
        if (x >= WorkAreaLeft and x <= WorkAreaRight and y >= WorkAreaTop and y <= WorkAreaBottom) {
            break
        }
    }
    WinGetPos nx, ny, nw, nh, A
    if (ox != nx or oy != ny or ow != nw or oh != nh) {
        if (Abs(WorkAreaLeft - nx) < mouse_offset) {
            nx := WorkAreaLeft
        }
        if (Abs(WorkAreaRight - nx - nw) < mouse_offset) {
            nx := WorkAreaRight - nw
        }
        if (Abs(WorkAreaTop - ny) < mouse_offset) {
            ny := WorkAreaTop
        }
        if (Abs(WorkAreaBottom - ny - nh) < mouse_offset) {
            ny := WorkAreaBottom - nh
        }
        WinMove nx, ny
    }
    return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Mouse Scroll
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

~*$LCtrl::
    if (!scroll_flag) {
        ;BlockInput MouseMove
        scroll_flag := 1
        CoordMode Mouse, Screen
        MouseGetPos old_x, old_y
        SetTimer moveScroll, % scroll_timer
    }
    return

~*$LCtrl Up::
    if (scroll_flag) {
        ;BlockInput MouseMoveOff
        scroll_flag := 0
        SetTimer moveScroll, Off
        old_x := 0
        old_y := 0
    }
    return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hot Corners
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;SetTimer hotCorners, % corner_timer

;*$LButton::
;    Send {LButton down}
;    CoordMode Mouse, Screen
;    MouseGetPos mdx, mdy
;    WinGetPos wdx, wdy, wdw, wdh, A
;    return
;*$LButton Up::
;    Send {LButton up}
;    CoordMode Mouse, Screen
;    MouseGetPos mux, muy
;    WinGetPos wux, wuy, wuw, wuh, A
;    if (Abs(mux - mdx) < mouse_offset) and (Abs(muy - mdy) < mouse_offset) {
;        return
;    }
;    if (Abs(wux - wdx) < win_offset) and (Abs(wuy - wdy) < win_offset) and (Abs(wuw - wdw) < win_offset) and (Abs(wuh - wdh) < win_offset) {
;        return
;    }
;    move := 0
;    if (Abs(wux - 0) < win_offset) {
;        wux := 0
;        move := 1
;    }
;    if (Abs(wuy - 0) < win_offset) {
;        wuy := 0
;        move := 1
;    }
;    if (Abs(wux + wuw - A_ScreenWidth) < win_offset) {
;        wux := A_ScreenWidth - wuw
;        move := 1
;    }
;    if (Abs(wuy + wuh - A_ScreenHeight) < win_offset) {
;        wuy := A_ScreenHeight - wuh
;        move := 1
;    }
;    if (move > 0) {
;        msg := "move: " wdx " " wdy " -> " wux " " wuy
;        createToolTip(msg, -3000)
;        WinMove A, , wux, wuy, wuw, wuh
;    }
;    return

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Komorebi
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!t::
    komorebi_prefix := 1
    createToolTip("komorebi", -3000)
    return

$t::
    if (komorebi_prefix) {
        komorebic("focus-last-workspace")
    } else {
        Send t
    }
    return

$m::
    if (komorebi_prefix) {
        komorebic("toggle-maximize")
    } else {
        Send m
    }
    return

$0::
    if (komorebi_prefix) {
        komorebic("focus-workspace 9")
    } else {
        Send 0
    }
    return
$1::
    if (komorebi_prefix) {
        komorebic("focus-workspace 0")
    } else {
        Send 1
    }
    return
$2::
    if (komorebi_prefix) {
        komorebic("focus-workspace 1")
    } else {
        Send 2
    }
    return
$3::
    if (komorebi_prefix) {
        komorebic("focus-workspace 2")
    } else {
        Send 3
    }
    return
$4::
    if (komorebi_prefix) {
        komorebic("focus-workspace 3")
    } else {
        Send 4
    }
    return
$5::
    if (komorebi_prefix) {
        komorebic("focus-workspace 4")
    } else {
        Send 5
    }
    return
$6::
    if (komorebi_prefix) {
        komorebic("focus-workspace 5")
    } else {
        Send 6
    }
    return
$7::
    if (komorebi_prefix) {
        komorebic("focus-workspace 6")
    } else {
        Send 7
    }
    return
$8::
    if (komorebi_prefix) {
        komorebic("focus-workspace 7")
    } else {
        Send 8
    }
    return
$9::
    if (komorebi_prefix) {
        komorebic("focus-workspace 8")
    } else {
        Send 9
    }
    return

$+0::
    if (komorebi_prefix) {
        komorebic("send-to-workspace 9")
    } else {
        Send +0
    }
    return
$+1::
    if (komorebi_prefix) {
        komorebic("send-to-workspace 0")
    } else {
        Send +1
    }
    return
$+2::
    if (komorebi_prefix) {
        komorebic("send-to-workspace 1")
    } else {
        Send +2
    }
    return
$+3::
    if (komorebi_prefix) {
        komorebic("send-to-workspace 2")
    } else {
        Send +3
    }
    return
$+4::
    if (komorebi_prefix) {
        komorebic("send-to-workspace 3")
    } else {
        Send +4
    }
    return
$+5::
    if (komorebi_prefix) {
        komorebic("send-to-workspace 4")
    } else {
        Send +5
    }
    return
$+6::
    if (komorebi_prefix) {
        komorebic("send-to-workspace 5")
    } else {
        Send +6
    }
    return
$+7::
    if (komorebi_prefix) {
        komorebic("send-to-workspace 6")
    } else {
        Send +7
    }
    return
$+8::
    if (komorebi_prefix) {
        komorebic("send-to-workspace 7")
    } else {
        Send +8
    }
    return
$+9::
    if (komorebi_prefix) {
        komorebic("send-to-workspace 8")
    } else {
        Send +9
    }
    return

$h::
    if (komorebi_prefix) {
        komorebic("focus left")
    } else {
        Send h
    }
    return
$j::
    if (komorebi_prefix) {
        komorebic("focus down")
    } else {
        Send j
    }
    return
$k::
    if (komorebi_prefix) {
        komorebic("focus up")
    } else {
        Send k
    }
    return
$l::
    if (komorebi_prefix) {
        komorebic("focus right")
    } else {
        Send l
    }
    return
