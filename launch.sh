#!/bin/bash

# إصلاح تنسيق الملف
sed -i 's/\r$//' "$0"

# تعطيل نهائي لـ TA-Lib
export DISABLE_TA=1
unset TA_LIBRARY_PATH

# استخدام orjson بدلاً من rapidjson
export FREQTRADE_JSON_MODULE=orjson

echo "بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ"
echo "🦅 بدء تشغيل الصقر الذهبي: $(date)"
echo "🚀 النسخة النهائية الخالية من TA-Lib"
echo "📈 استخدام orjson للتداول السريع"

# الانتقال لمجلد العمل
cd /app

# تشغيل البوت مع مراقبة مستمرة
while true; do
    python -m freqtrade trade --strategy GoldenEagleStrategy --config user_data/config.json
    
    # نظام التعافي التلقائي
    if [ $? -ne 0 ]; then
        echo "⚠️ حدث خطأ، إعادة التشغيل خلال 10 ثوان..."
        sleep 10
    else
        echo "✅ تم إنهاء التشغيل بنجاح"
        break
    fi
done