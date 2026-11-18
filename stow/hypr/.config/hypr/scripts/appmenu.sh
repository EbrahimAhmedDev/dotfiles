#!/usr/bin/env bash
# Two-level app launcher (KDE-style): pick a category, then pick an app.
# Opens with SUPER + S. First entry is a full-text search (old rofi drun).
# UI text is English by design.
exec python3 - "$@" <<'PY'
import configparser, glob, os, re, shlex, subprocess, sys


CAT_ICONS = {
    "Development": "applications-development",
    "Education":   "applications-education",
    "Game":        "applications-games",
    "Graphics":    "applications-graphics",
    "Internet":    "applications-internet",
    "Multimedia":  "applications-multimedia",
    "Office":      "applications-office",
    "Science":     "applications-science",
    "Settings":    "preferences-system",
    "System":      "applications-system",
    "Utility":     "applications-utilities",
    "Other":       "applications-other",
}
SEARCH = "All Applications (type to search)"

# XDG main categories, in menu order
MAIN = ["AudioVideo", "Development", "Education", "Game", "Graphics", "Internet",
        "Office", "Science", "Settings", "System", "Utility", "Accessibility"]
ALIAS = {"Network": "Internet", "Multimedia": "AudioVideo", "Audio": "AudioVideo",
         "Video": "AudioVideo", "Telephony": "Internet", "FileTransfer": "Internet"}

def first_main(categories: str) -> str:
    parts = [p for p in categories.split(";") if p]
    for m in MAIN:
        if m in parts:
            return {"AudioVideo": "Multimedia", "Accessibility": "Other"}.get(m, m)
    for p in parts:
        if p in ALIAS:
            return ALIAS[p]
    return "Other"

def clean_exec(exec_line: str) -> str:
    exec_line = re.sub(r"%[fFuUdDnNickvm]", "", exec_line)   # drop field codes
    exec_line = exec_line.replace("%%", "%")
    return " ".join(exec_line.split())

def load_apps():
    dirs = ["/usr/share/applications",
            os.path.expanduser("~/.local/share/applications"),
            "/usr/local/share/applications"]
    files = []
    for d in dirs:
        files += glob.glob(os.path.join(d, "**", "*.desktop"), recursive=True)
    rows = []
    for f in sorted(set(files)):
        try:
            cp = configparser.ConfigParser(interpolation=None, strict=False)
            cp.optionxform = str
            cp.read(f, encoding="utf-8")
        except Exception:
            continue
        if "Desktop Entry" not in cp:
            continue
        s = cp["Desktop Entry"]
        if s.get("Type", "Application") != "Application":
            continue
        if s.get("NoDisplay", "").lower() in ("true", "1") or \
           s.get("Hidden", "").lower() in ("true", "1"):
            continue
        name = s.get("Name", "").strip()
        exe = clean_exec(s.get("Exec", ""))
        if not name or not exe:
            continue
        rows.append((first_main(s.get("Categories", "")), name,
                     s.get("Icon", "").strip() or "application-x-executable",
                     exe, s.get("Terminal", "").lower() in ("true", "1")))
    rows.sort(key=lambda r: (r[0] != "Other", r[0].lower(), r[1].lower()))
    return rows

def rofi_pick(prompt, entries, mesg, width="480px", fmt="i", extra=None):
    """entries: list of (display, icon). Returns rofi output per fmt, or None (Esc)."""
    args = ["rofi", "-dmenu", "-i", "-show-icons", "-format", fmt,
            "-p", prompt, "-theme-str", f"window {{ width: {width}; }}"]
    if extra:
        args += extra
    if mesg:
        args += ["-mesg", mesg]
    data = "".join(
        d + ("\0icon\x1f" + ic if ic else "") + "\n" for d, ic in entries)
    p = subprocess.run(args, input=data.encode(), stdout=subprocess.PIPE,
                       stderr=subprocess.DEVNULL)
    if p.returncode != 0 or not p.stdout.strip():
        return None
    out = p.stdout.decode(errors="replace").strip()
    if fmt == "i":
        try:
            return int(out)
        except ValueError:
            return None
    return out

def launch(exe, terminal):
    if terminal:
        exe = "ghostty -e bash -c " + shlex.quote(exe)
    subprocess.Popen(exe, shell=True, start_new_session=True,
                     stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

rows = load_apps()
if not rows:
    subprocess.run(["notify-send", "-u", "critical", "Apps", "No applications found."])
    sys.exit(1)

# --- debug flags (used by the agent / for maintenance) ---
if len(sys.argv) > 1:
    if sys.argv[1] == "--cats":
        seen = {}
        for c, *_ in rows:
            seen[c] = seen.get(c, 0) + 1
        for c in sorted(seen):
            print(f"{c} ({seen[c]})")
        sys.exit(0)
    if sys.argv[1] == "--apps" and len(sys.argv) > 2:
        for c, n, ic, *_ in rows:
            if c == sys.argv[2]:
                print(f"{n}\t{ic}")
        sys.exit(0)

# --- main two-level flow ---
cats = sorted({c for c, *_ in rows if c != "Other"})
if any(c == "Other" for c, *_ in rows):
    cats.append("Other")
cat_counts = {c: sum(1 for r in rows if r[0] == c) for c in cats}

def show_search(text):
    subprocess.run(["rofi", "-show", "drun", "-filter", text])
    sys.exit(0)

level = "cats"
while True:
    if level == "cats":
        entries = [(SEARCH, "system-search")]
        entries += [(f"{c}  ({cat_counts[c]})", CAT_ICONS.get(c, "applications-other"))
                    for c in cats]
        by_display = {d: i for i, (d, _) in enumerate(entries)}
        # -format s so typed text that matches no category = search all apps
        out = rofi_pick("Apps", entries,
                        "Pick a category — or type any text to search all apps",
                        width="480px", fmt="s")
        if out is None:
            sys.exit(0)
        if out in by_display:
            idx = by_display[out]
            if idx == 0:                    # "All Applications" → search
                show_search("")
            current = cats[idx - 1]
            level = "apps"
        else:
            show_search(out)                # typed text → search all apps
    else:
        apps = [(n, ic) for c, n, ic, *_ in rows if c == current]
        idx = rofi_pick(current, apps,
                        f"{len(apps)} apps — Esc to go back",
                        width="560px", fmt="i", extra=["-no-custom"])
        if idx is None:                     # back to categories
            level = "cats"
            continue
        target = next(r for r in rows if r[0] == current and r[1] == apps[idx][0])
        launch(target[3], target[4])
        sys.exit(0)
PY
