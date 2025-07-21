#!/bin/bash

# إصلاح تنسيق الملف
sed -i 's/\r$//' "$0"

# تعطيل نهائي لـ TA-Lib
export DISABLE_TA=1
unset TA_LIBRARY_PATH

# استخدام orjson للتداول السريع
export FREQTRADE_JSON_MODULE=orjson

echo "بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ"
echo "🦅 بدء تشغيل الصقر الذهبي: $(date)"
echo "🚀 النسخة النهائية المستقرة"
echo "📊 إصدار Freqtrade: 2025.4"

# الانتقال لمجلد العمل
cd /app

# التأكد من تعطيل TA-Lib
python -c "import sys; assert 'talib' not in sys.modules, 'TA-Lib still loaded!'"

# تشغيل البوت مع مراقبة مستمرة
while true; do
    freqtrade trade --strategy GoldenEagleStrategy --config user_data/config.json
    
    # نظام التعافي التلقائي
    if [ $? -ne 0 ]; then
        echo "⚠️ حدث خطأ، إعادة التشغيل خلال 10 ثوان..."
        sleep 10
    else
        echo "✅ صقرنا يحلق بنجاح!"
        break
    fi
done