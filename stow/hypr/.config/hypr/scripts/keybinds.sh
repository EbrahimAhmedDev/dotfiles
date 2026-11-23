#!/usr/bin/env bash
# Keybinds cheat sheet — AUTO-GENERATED from ~/.config/hypr/modules/keybinds.lua.
# Every new hl.bind() added to that file shows up here automatically.
# Usage: keybinds.sh          → rofi overlay (SUPER + N)
#        keybinds.sh --print  → plain text (debugging)
# UI text is English by design.
set -u

list=$(KEYBINDS_LUA="${KEYBINDS_LUA:-$HOME/.config/hypr/modules/keybinds.lua}" python3 <<'PY'
import os, re, sys

lua_path = os.path.expandvars(os.environ.get("KEYBINDS_LUA", ""))
try:
    text = open(lua_path, encoding="utf-8").read()
except OSError as e:
    print(f"  (cannot read keybinds.lua: {e})")
    sys.exit(0)

MOUSE = {"mouse:272": "Left mouse drag", "mouse:273": "Right mouse drag"}
KEYLABEL = {
    "XF86AudioRaiseVolume": "Volume Up", "XF86AudioLowerVolume": "Volume Down",
    "XF86AudioMute": "Mute", "XF86AudioMicMute": "Mic mute",
    "XF86MonBrightnessUp": "Brightness Up", "XF86MonBrightnessDown": "Brightness Down",
    "XF86AudioPlay": "Play / Pause", "XF86AudioNext": "Next track",
    "XF86AudioPrev": "Previous track", "XF86Tools": "Fn + F9",
}

# command → English description (first match wins)
EXEC_DESCS = [
    (r"ghostty", "Terminal (Ghostty)"),
    (r"rofi -show drun", "App launcher (rofi)"),
    (r"rofi -show run", "Run a command (rofi)"),
    (r"control\.sh", "Control menu (themes, OCR/QR, update, power)"),
    (r"ocr\.sh", "Extract text or QR from screen"),
    (r"keybinds\.sh", "This cheat sheet"),
    (r"clipse", "Clipboard history (clipse)"),
    (r"google-chrome", "Web browser (Chrome)"),
    (r"firefox", "Web browser (Firefox)"),
    (r"^spotify$", "Music (Spotify)"),
    (r"dolphin", "File manager (Dolphin)"),
    (r"nightlight\.sh", "Night light"),
    (r"loginctl lock-session", "Lock screen"),
    (r"^wlogout$", "Power menu (logout / sleep / reboot / off)"),
    (r"hyprpicker", "Color picker (copies the color)"),
    (r"screenshot-edit\.sh", "Select area -> annotate (Satty)"),
    (r"screenshot\.sh", "Full screenshot"),
    (r"^kooha$", "Start / stop screen recording (Kooha)"),
    (r"osd\.sh vol-", "Change volume (OSD + click sound)"),
    (r"osd\.sh mute", "Mute / unmute audio"),
    (r"osd\.sh mic-mute", "Mute / unmute microphone"),
    (r"osd\.sh bright", "Screen brightness"),
    (r"playerctl play-pause", "Media play / pause"),
    (r"playerctl next", "Media next track"),
    (r"playerctl previous", "Media previous track"),
    (r"hyprmod", "Hyprmod quick launcher"),
]

def exec_desc(cmd):
    for pat, desc in EXEC_DESCS:
        if re.search(pat, cmd):
            return desc
    return None

def disp_desc(d):
    d = d.strip()
    if "window.close" in d:            return "Close focused window"
    if "window.fullscreen" in d:       return "Fullscreen toggle"
    if "window.float" in d:            return "Floating window toggle"
    if re.fullmatch(r"exit\(\)", d):   return "Log out of Hyprland"
    m = re.search(r'direction = "(\w+)"', d)
    if d.startswith("focus(") and m:   return f"Focus window: {m.group(1).capitalize()}"
    if "window.move(" in d and m:      return f"Move window: {m.group(1).capitalize()}"
    if "window.resize(" in d:
        if "x = -40" in d: return "Resize window: Left"
        if "x = 40" in d:  return "Resize window: Right"
        if "y = -40" in d: return "Resize window: Up"
        if "y = 40" in d:  return "Resize window: Down"
        return "Resize window"
    if "window.drag(" in d:            return "Move floating window"
    if "layout(" in d:                 return "Reset split ratio to 50/50"
    return None

# --- `local name = lua-string-expression` environment ---
env = {}
for m in re.finditer(r'^\s*local\s+(\w+)\s*=\s*(.+?)\s*(?:--.*)?$', text, re.M):
    env[m.group(1)] = m.group(2)

def ev(expr):
    out = ""
    for part in re.split(r"\s*\.\.\s*", expr.strip()):
        part = part.strip()
        if len(part) >= 2 and part[0] == '"' and part[-1] == '"':
            out += part[1:-1]
        elif part == "key":                       # loop variable (BEFORE env)
            out += "\x00key\x00"
        elif part in env:
            sub = ev(env[part])
            if sub is None:
                return None
            out += sub
        else:
            return None
    return out

ARABIC = re.compile(r"[\u0600-\u06FF]")

def ascii_comment(c):
    c = c.strip().lstrip("-").strip()
    if not c or ARABIC.search(c) or "Dux Shell" in c or c.startswith("NOTE"):
        return None
    return c

def split_comment(s):
    """Split code from a trailing '--' comment, ignoring '--' inside strings
    (e.g. ghostty --class=...). Returns (code, comment_or_None)."""
    in_str, q, j = False, "", 0
    while j < len(s):
        ch = s[j]
        if in_str:
            if ch == q:
                in_str = False
        elif ch in "\"'":
            in_str, q = True, ch
        elif ch == "-" and j + 1 < len(s) and s[j + 1] == "-":
            return s[:j], s[j + 2:]
        j += 1
    return s, None

# --- join multi-line statements (e.g. the clipse bind spans 3 lines) ---
def paren_balance(s):
    d, in_str, q = 0, False, ""
    for ch in s:
        if in_str:
            if ch == q:
                in_str = False
        elif ch in "\"'":
            in_str, q = True, ch
        elif ch == "(":
            d += 1
        elif ch == ")":
            d -= 1
    return d

statements, buf = [], ""
for raw in text.splitlines():
    if buf:
        buf += "\n" + raw
    else:
        buf = raw
    if paren_balance(buf) <= 0:
        statements.append(buf)
        buf = ""
if buf.strip():
    statements.append(buf)

out = []
pending = None
for stmt in statements:
    lines = stmt.splitlines()
    if not lines:
        continue
    first = lines[0]
    stripped = first.strip()

    # standalone comment → candidate section header / description
    if stripped.startswith("--") and len(lines) == 1:
        c = ascii_comment(stripped)
        if c and not pending:          # keep the first (section) comment
            pending = c
        continue

    code, inline_raw = split_comment(stmt)

    # helper binds: hl.bind(combo, move_floating(dx, dy), { repeating = true })
    fm = re.match(r"\s*hl\.bind\(\s*(.*?)\s*,\s*move_floating\(\s*(-?\d+)\s*,\s*(-?\d+)\s*\)", code, re.S)
    if fm:
        combo = ev(fm.group(1))
        if combo:
            dx, dy = int(fm.group(2)), int(fm.group(3))
            direction = ("Left" if dx < 0 else "Right") if dx else ("Up" if dy < 0 else "Down")
            if pending:
                out.append(("H", pending))
                pending = None
            for k, v in KEYLABEL.items():
                if combo == k:
                    combo = v
            combo = re.sub(r"(?<=\+ )([a-z])", lambda x: x.group(1).upper(), combo)
            out.append((combo, "Move floating window: " + direction))
        continue

    m = re.match(r"\s*hl\.bind\((.*),\s*hl\.dsp\.(.*)\)\s*$", code, re.S)
    if not m:
        continue
    expr, rest = m.group(1), m.group(2)

    dm = re.match(r"(.*?\))(?:,\s*(\{.*\}))?\s*$", rest, re.S)
    dispatch, flags = (dm.group(1), dm.group(2) or "") if dm else (rest, "")

    combo = ev(expr)
    if not combo:
        continue

    inline = ascii_comment(inline_raw) if inline_raw else None

    desc = None
    if dispatch.startswith("exec_cmd("):
        cmd = ev(dispatch[len("exec_cmd("):-1])
        if cmd:
            desc = exec_desc(cmd.strip()) or inline
    if desc is None:
        desc = disp_desc(dispatch)
    if desc is None:
        desc = inline
    if desc is None and "\x00key\x00" in combo and "workspace" in dispatch:
        combo = combo.replace("\x00key\x00", "1-9")
        desc = "Switch to workspace" if dispatch.startswith("focus(") \
               else "Move window to workspace"
    if desc is None and pending:
        desc = pending
        pending = None

    # section header before the entry (pending not consumed as description)
    if pending:
        out.append(("H", pending))
        pending = None
    if desc is None:
        desc = dispatch[:60]

    for k, v in KEYLABEL.items():
        if combo == k:
            combo = v
    for k, v in MOUSE.items():
        combo = combo.replace(k, v)
    combo = re.sub(r"(?<=\+ )([a-z])", lambda x: x.group(1).upper(), combo)
    if "\x00key\x00" in combo:
        continue

    suffix = " · locked" if "locked = true" in flags else ""
    out.append((combo, desc + suffix))

if pending:
    out.append(("H", pending))
if not out:
    print("  (no keybinds parsed — check keybinds.lua syntax)")

for combo, desc in out:
    if combo == "H":
        print()
        print(f"──  {desc}  ──")
    else:
        print(f"  {combo:<28} →  {desc}")
PY
)

if [ "${1:-}" = "--print" ]; then
    printf '%s\n' "$list"
    exit 0
fi

printf '%s\n' "$list" | rofi -dmenu -i -p "Keybinds" \
    -mesg "Auto-generated from keybinds.lua — Esc to close" \
    -theme-str 'window { width: 58%; }'
