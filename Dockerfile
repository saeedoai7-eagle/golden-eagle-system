FROM python:3.11-slim

# تثبيت المتطلبات الأساسية
RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libffi-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# إنشاء بيئة افتراضية
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# نسخ وتركيب المتطلبات
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# نسخ ملفات المشروع
COPY . /app
WORKDIR /app

# تشغيل آلية الأمان
RUN python -c "from oath import secure_keys; secure_keys()"

# تشغيل السكربت الرئيسي
CMD ["bash", "launch.sh"]