# syntax=docker/dockerfile:1.4
FROM python:3.11-slim-bullseye

# تثبيت التبعيات الأساسية
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# إنشاء مسار العمل
WORKDIR /app

# نسخ جميع ملفات المشروع
COPY . /app

# تثبيت المتطلبات بدون TA-Lib
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir numpy pandas scipy && \
    pip install --no-cache-dir pandas-ta ccxt requests && \
    pip install --no-cache-dir freqtrade==2025.5 --no-deps && \
    pip install --no-cache-dir -U freqtrade

# تعيين الأذونات
RUN chmod +x launch.sh

# تشغيل البوت
CMD ["/bin/bash", "launch.sh"]