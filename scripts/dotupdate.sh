#!/usr/bin/env bash
# التحديث الموحد: مستودعات + AUR + تنظيف كاش pacman
# يشتغل من التيرمنال: dotupdate   (أو من قائمة التحكم SUPER+CTRL+S)

echo "🔄 التحديث الموحد"
echo "══════════════════"
echo
echo "⏳ بيفحص التحديثات..."

repos=$(checkupdates 2>/dev/null | wc -l)
aur=$(yay -Qua 2>/dev/null | wc -l)
total=$((repos + aur))

if [ "$total" -eq 0 ]; then
    echo "✅ مفيش أي تحديثات — النظام حدث بالكامل."
    notify-send "🔄 التحديث" "مفيش تحديثات ✅"
    read -rn1 -k "?اضغط أي زر للقفل..."
    exit 0
fi

echo "📦 متاح: $repos من المستودعات + $aur من AUR (إجمالاً $total)"
echo "────────────────────────────"
checkupdates 2>/dev/null | head -20
[ "$aur" -gt 0 ] && echo "... + $aur حزمة من AUR"
echo "────────────────────────────"
echo
read -rp "نفّذ التحديث كله؟ [y/N] " answer
case "$answer" in [yY]*) ;; *) echo "تم اللغاء."; exit 0 ;; esac

if yay -Syu; then
    echo
    echo "🧹 بتنضف كاش pacman (يبقي آخر نسخة لكل حزمة)..."
    sudo paccache -rk1 2>/dev/null || true
    notify-send "🔄 التحديث" "خلص بنجاح ✅"
    echo "✅ التحديث خلص."
else
    notify-send -u critical "🔄 التحديث" "فيه فشل ❌ (شوف الأخطاء فوق)"
    echo "❌ التحديث فشل — شوف الأخطاء فوق."
fi
read -rn1 -k "?اضغط أي زر للقفل..."
