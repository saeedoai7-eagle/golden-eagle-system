# تحديد إصدار Docker الصريح
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
RUN mkdir -p /app/golden_eagle_system
WORKDIR /app

# تثبيت Freqtrade والإضافات
RUN pip install --upgrade pip
RUN pip install freqtrade==2025.5 pandas-ta ccxt requests

# نسخ ملفات المشروع
COPY golden_eagle_system /app/golden_eagle_system

# تعيين الأذونات
RUN chmod +x /app/golden_eagle_system/launch.sh

# تشغيل البوت
CMD ["/bin/bash", "/app/golden_eagle_system/launch.sh"]