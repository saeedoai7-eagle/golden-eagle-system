# بناء Freqtrade مخصص بدون rapidjson
FROM python:3.11-slim-bullseye AS builder

# تثبيت التبعيات للبناء
RUN apt-get update && apt-get install -y git build-essential

# تحميل شيفرة Freqtrade
RUN git clone https://github.com/freqtrade/freqtrade.git /freqtrade-src
WORKDIR /freqtrade-src
RUN git checkout 2025.5

# إزالة rapidjson نهائياً
RUN sed -i '/import rapidjson/d' freqtrade/commands/pairlist_commands.py && \
    sed -i 's/rapidjson/json/g' freqtrade/commands/pairlist_commands.py && \
    sed -i '/rapidjson/d' pyproject.toml

# بناء الإصدار المعدل
RUN pip install --upgrade pip && \
    pip install poetry && \
    poetry build -f wheel

# ---------- البناء النهائي ----------
FROM python:3.11-slim-bullseye

# تثبيت التبعيات الأساسية
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# نسخ Freqtrade المعدل
WORKDIR /app
COPY --from=builder /freqtrade-src/dist/freqtrade-2025.5-py3-none-any.whl .

# تثبيت Freqtrade المخصص
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir freqtrade-2025.5-py3-none-any.whl && \
    pip install --no-cache-dir numpy==1.26.4 pandas==2.2.2 scipy==1.13.0 && \
    pip install --no-cache-dir pandas-ta==0.3.14b0 ccxt==4.3.20 requests==2.32.3 orjson==3.10.3

# نسخ ملفات المشروع
COPY . .

# إعدادات نهائية
RUN chmod +x launch.sh && \
    sed -i 's/\r$//' launch.sh && \
    mkdir -p /app/user_data/strategies

# تشغيل البوت
CMD ["/bin/bash", "launch.sh"]