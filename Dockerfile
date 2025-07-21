# Dockerfile النهائي المضمون
# syntax=docker/dockerfile:1.4
FROM python:3.11-slim-bullseye

# تثبيت التبعيات الأساسية
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# إنشاء مسار العمل
WORKDIR /app

# نسخ جميع الملفات الضرورية
COPY . .

# إصلاح تنسيق الملفات لتناسب لينكس
RUN sed -i 's/\r$//' launch.sh

# تثبيت المتطلبات الكاملة مع orjson بدلاً من rapidjson
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir numpy==1.26.4 pandas==2.2.2 scipy==1.13.0 && \
    pip install --no-cache-dir pandas-ta==0.3.14b0 ccxt==4.3.20 requests==2.32.3 orjson==3.10.3 && \
    pip install --no-cache-dir freqtrade==2025.4

# تعطيل TA-Lib نهائياً
RUN pip uninstall -y TA-Lib 2>/dev/null || true && \
    echo 'import sys; sys.modules["talib"] = None' > /usr/local/lib/python3.11/site-packages/talib_disable.py && \
    echo 'import talib_disable' >> /usr/local/lib/python3.11/site-packages/sitecustomize.py

# إنشاء مجلد الاستراتيجيات ونسخ الملفات
RUN mkdir -p /app/user_data/strategies
COPY config.json /app/user_data/
COPY strategies/GoldenEagleStrategy.py /app/user_data/strategies/

# تعيين الأذونات
RUN chmod +x launch.sh

# تشغيل البوت
CMD ["/bin/bash", "launch.sh"]