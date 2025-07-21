#!/bin/bash

# تأكيد إصلاح تنسيق الملف
sed -i 's/\r$//' "$0"

# تعطيل نهائي لـ TA-Lib
export DISABLE_TA=1
unset TA_LIBRARY_PATH

# استخدام orjson للتداول السريع
export FREQTRADE_JSON_MODULE=orjson

echo "بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ"
echo "🦅 بدء تشغيل الصقر الذهبي: $(date)"
echo "🚀 النسخة المعدلة بدون rapidjson"
echo "🔥 Freqtrade مخصص من صنع شراكتنا"

# الانتقال لمجلد العمل
cd /app

# تشغيل البوت
while true; do
    freqtrade trade --strategy GoldenEagleStrategy --config user_data/config.json
    
    if [ $? -ne 0 ]; then
        echo "⚠️ حدث خطأ، إعادة التشغيل خلال 10 ثوان..."
        sleep 10
    else
        echo "✅ صقرنا يحلق بنجاح!"
        break
    fi
done