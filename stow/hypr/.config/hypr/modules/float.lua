-- modules/float.lua
-- When a tiled window becomes floating: shrink it to 60% of the screen and
-- center it, so a floating window never looks like a maximized one.
-- (Floating outline color lives in rules.lua -> floating-outline rule.)

local SCREEN_FILL = 0.6 -- 60% of the monitor

local was_float = {}

local function shrink_if_newly_floating(w)
    if not w or not w.address then
        return
    end
    local addr = tostring(w.address)
    local now = w.floating and true or false
    local prev = was_float[addr]
    was_float[addr] = now
    -- only on the transition tiled -> floating (and only for the focused window)
    if not (now and prev == false and w.active) then
        return
    end
    -- a floating fullscreen/maximized window must lose that state first
    if w.fullscreen and w.fullscreen ~= 0 then
        hl.dispatch(hl.dsp.window.fullscreen_state({ internal = 0, client = 0 }))
    end
    local mon = w.monitor
    if not mon then
        return
    end
    local scale = mon.scale or 1
    local tw = math.floor(mon.width / scale * SCREEN_FILL)
    local th = math.floor(mon.height / scale * SCREEN_FILL)
    local sz = w.size
    -- Set every resizable floating window to 60% of the monitor.
    -- Never enlarge a window that intentionally has a fixed/small size.
    -- (size min/max constraints are honored by Hyprland when resize is dispatched.)
    if sz then
        hl.dispatch(hl.dsp.window.resize({ x = tw, y = th }))
    end
    hl.dispatch(hl.dsp.window.center())
end

hl.on("window.update_state", shrink_if_newly_floating)

-- record initial state when a window opens, so the tiled -> floating
-- transition can be detected (nil prev would otherwise be skipped)
hl.on("window.open", function(w)
    if w and w.address then
        was_float[tostring(w.address)] = w.floating and true or false
    end
end)

-- forget destroyed windows (keeps the table small)
hl.on("window.destroy", function(w)
    if w and w.address then
        was_float[tostring(w.address)] = nil
    end
end)

-- remember current state of already-open windows (no shrink for them)
for _, w in ipairs(hl.get_windows()) do
    was_float[tostring(w.address)] = w.floating and true or false
end
