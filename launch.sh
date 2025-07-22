#!/bin/bash

echo "بسم الله الرحمن الرحيم"
echo "🦅 الإصدار النهائي للصقر الذهبي - بدون TA-Lib"

# حل مشكلة المنطقة الجغرافية
export TZ="Asia/Riyadh"
ln -snf /usr/share/zoneinfo/$TZ /etc/localtime

# فك تشفير المفاتيح
API_KEY=$(python -c "from cryptography.fernet import Fernet; import os; cipher = Fernet(os.environ['CRYPTO_KEY'].encode()); print(cipher.decrypt(os.environ['BINANCE_API_ENC'].encode()).decode())")
SECRET_KEY=$(python -c "from cryptography.fernet import Fernet; import os; cipher = Fernet(os.environ['CRYPTO_KEY'].encode()); print(cipher.decrypt(os.environ['BINANCE_SECRET_ENC'].encode()).decode())")

# تحديث ملف الإعدادات
python -c "import json; config=json.load(open('config.json')); config['exchange']['key']='$API_KEY'; config['exchange']['secret']='$SECRET_KEY'; json.dump(config, open('config.json','w'), indent=4)"

# التشغيل الدائم مع المراقبة
while true; do
    echo "$(date) - بدء دورة تداول جديدة"
    python -m freqtrade trade --strategy GoldenEagleStrategy --config config.json
    
    if [ $? -ne 0 ]; then
        echo "⚠️ تم الكشف عن توقف غير متوقع، إعادة التشغيل خلال 30 ثانية"
        sleep 30
    fi
done