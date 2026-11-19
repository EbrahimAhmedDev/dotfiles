local mainMod = "SUPER"
local secondMod = "SUPER + SHIFT"
local thirdMod = "SUPER + CTRL"

local scripts = "~/.config/hypr/scripts/"
local osd = scripts .. "osd.sh"

-- Apps
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("google-chrome-stable"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("spotify"))
hl.bind(secondMod .. " + F", hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("rofi -show drun -show-icons")) -- App launcher
hl.bind(secondMod .. " + S", hl.dsp.exec_cmd("rofi -show run"))
hl.bind(thirdMod .. " + S", hl.dsp.exec_cmd(scripts .. "control.sh")) -- قائمة التحكم المركزية
hl.bind(secondMod .. " + O", hl.dsp.exec_cmd(scripts .. "ocr.sh")) -- OCR: نص من جزء الشاشة

-- Clipboard history (clipse)
hl.bind(mainMod .. " + V",
    hl.dsp.exec_cmd("ghostty --class=com.clipse.tui --gtk-single-instance=false -e clipse",
        { float = true, size = { 522, 552 }, stay_focused = true }))

-- Window and session control
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(secondMod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("loginctl lock-session"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("wlogout"))
hl.bind(thirdMod .. " + Q", hl.dsp.exit())

-- Focus
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Move windows
hl.bind(secondMod .. " + left", hl.dsp.window.move({ direction = "left" }))
hl.bind(secondMod .. " + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(secondMod .. " + up", hl.dsp.window.move({ direction = "up" }))
hl.bind(secondMod .. " + down", hl.dsp.window.move({ direction = "down" }))

-- Resize windows
hl.bind(thirdMod .. " + left", hl.dsp.window.resize({ x = -40, y = 0, relative = true }), { repeating = true })
hl.bind(thirdMod .. " + right", hl.dsp.window.resize({ x = 40, y = 0, relative = true }), { repeating = true })
hl.bind(thirdMod .. " + up", hl.dsp.window.resize({ x = 0, y = -40, relative = true }), { repeating = true })
hl.bind(thirdMod .. " + down", hl.dsp.window.resize({ x = 0, y = 40, relative = true }), { repeating = true })

-- Reset split ratio (back to 50/50)
hl.bind(thirdMod .. " + R", hl.dsp.layout("splitratio 1 exact"))

-- Move floating window freely (SUPER + ALT + arrows), like SUPER + mouse drag
local function move_floating(dx, dy)
    return function()
        for _, w in ipairs(hl.get_windows()) do
            if w.active and w.floating and w.fullscreen == 0 then
                hl.dispatch(hl.dsp.window.move({ x = dx, y = dy, relative = true }))
                return
            end
        end
    end
end

hl.bind(mainMod .. " + ALT + left", move_floating(-40, 0), { repeating = true })
hl.bind(mainMod .. " + ALT + right", move_floating(40, 0), { repeating = true })
hl.bind(mainMod .. " + ALT + up", move_floating(0, -40), { repeating = true })
hl.bind(mainMod .. " + ALT + down", move_floating(0, 40), { repeating = true })

-- Workspaces 1-9
for i = 1, 9 do
    local key = tostring(i)
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(secondMod .. " + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Mouse: move and resize
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume and brightness (with on-screen bar)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(osd .. " vol-up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(osd .. " vol-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(osd .. " mute"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(osd .. " mic-mute"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(osd .. " bright-up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(osd .. " bright-down"), { locked = true, repeating = true })

-- Media keys
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Screenshots and recording
-- Print: area (Satty) | Shift+Print: full screen | Super+Print: recording
hl.bind("Print", hl.dsp.exec_cmd(scripts .. "screenshot-edit.sh"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(scripts .. "screenshot.sh full"))
hl.bind("SUPER + Print", hl.dsp.exec_cmd("kooha"))

-- Utilities
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd(scripts .. "keybinds.sh")) -- keybinds cheat sheet
hl.bind(secondMod .. " + C", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind("XF86Tools", hl.dsp.exec_cmd("hyprmod")) -- Fn + F9
