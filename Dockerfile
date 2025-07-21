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

# حل جذري: تثبيت Freqtrade بدون أي تبعيات لـ TA-Lib
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir numpy pandas scipy && \
    pip install --no-cache-dir pandas-ta==0.3.14b0 ccxt==4.3.20 requests==2.32.3 && \
    pip install --no-cache-dir freqtrade==2025.5 --no-deps && \
    pip uninstall -y TA-Lib 2>/dev/null || true

# منع أي محاولة لاستخدام TA-Lib نهائياً
RUN echo 'import sys; sys.modules["talib"] = None' > /usr/local/lib/python3.11/site-packages/talib_disable.py && \
    echo 'import talib_disable' >> /usr/local/lib/python3.11/site-packages/sitecustomize.py

# إنشاء مجلد الاستراتيجيات
RUN mkdir -p /app/user_data/strategies

# نسخ ملفات التهيئة
COPY config.json /app/user_data/
COPY strategies/GoldenEagleStrategy.py /app/user_data/strategies/

# تعيين الأذونات
RUN chmod +x launch.sh
RUN sed -i 's/\r$//' launch.sh

# تشغيل البوت
CMD ["/bin/bash", "launch.sh"]