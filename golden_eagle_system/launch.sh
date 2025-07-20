#!/bin/bash

echo "بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ"
echo "🦅 بدء تشغيل الصقر الذهبي: $(date)"
echo "🧠 النسخة الذهبية 5.0 - بفضل الله"

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