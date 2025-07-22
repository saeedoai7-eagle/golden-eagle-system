FROM python:3.11-slim

# تنظيف تام لـ TA-Lib
RUN apt-get update && apt-get purge -y libta-lib*

# التبعيات الأساسية
RUN apt-get install -y build-essential libssl-dev libffi-dev git

# إنشاء بيئة افتراضية
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# نسخ وتركيب المتطلبات
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# نسخ ملفات المشروع
COPY . /app
WORKDIR /app

# تشغيل آلية الأمان
RUN python oath.py

# تشغيل السكربت الرئيسي
CMD ["bash", "launch.sh"]