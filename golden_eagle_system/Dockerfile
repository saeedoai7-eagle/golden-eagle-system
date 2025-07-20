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
COPY . .

# تثبيت المتطلبات
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir freqtrade==2025.5 pandas-ta ccxt requests

# تعيين الأذونات
RUN chmod +x launch.sh

# تشغيل البوت
CMD ["/bin/bash", "launch.sh"]