#!/bin/bash

# الانتقال إلى مجلد المشروع
cd /app/golden_eagle_system

# تشغيل البوت مع مراقبة مستمرة
while true; do
    echo "بسم الله الرحمن الرحيم"
    echo "🦅 إطلاق الصقر الذهبي: $(date)"
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