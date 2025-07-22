import os
from cryptography.fernet import Fernet

def secure_keys():
    key = Fernet.generate_key()
    cipher = Fernet(key)
    
    # استبدل بالمفاتيح الحقيقية
    api_key = "k8AOpm1zwOHLLF0ZGvpORlx0pFa6BbOaKJ78y2CilCDS1k9dxKYCUVIWwpJutuO7"
    secret = "kNuwxtsYqm9xfI39qYl3ChUOJ7dGKqAdFTlNhEJ6Qmr61EzbXXu5EeuTj8TB0cc5"
    
    encrypted_api = cipher.encrypt(api_key.encode())
    encrypted_secret = cipher.encrypt(secret.encode())
    
    print("انسخ هذه القيم لاستخدامها في Koyeb:")
    print(f"CRYPTO_KEY: {key.decode()}")
    print(f"BINANCE_API_ENC: {encrypted_api.decode()}")
    print(f"BINANCE_SECRET_ENC: {encrypted_secret.decode()}")
    
    return "تم التشفير بنجاح!"

if __name__ == "__main__":
    print(secure_keys())
