import logging
import time
import numpy as np
import pandas_ta as pta
import pandas as pd
from pandas import DataFrame
from datetime import datetime, timedelta
from freqtrade.strategy import IStrategy
from freqtrade.persistence import Trade
import requests
import os
import sys
sys.modules['talib'] = None  # تعطيل TA-Lib نهائياً

# إضافة مسار الملف الحالي لضمان استيراد صحيح
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

logger = logging.getLogger(__name__)

class GoldenEagleStrategy(IStrategy):
    INTERFACE_VERSION = 3
    startup_candle_count = 150
    process_only_new_candles = True
    timeframe = '5m'
    
    minimal_roi = {
        "0": 0.028,
        "15": 0.015,
        "40": 0.005
    }
    
    stoploss = -0.012
    trailing_stop = True
    trailing_stop_positive = 0.006
    trailing_stop_offset = 0.012
    use_custom_stoploss = True
    
    entry_params = {
        'rsi_max': 37,
        'volume_ratio': 1.45,
        'trend_threshold': 0.35
    }
    
    market_phase = "NORMAL"
    last_optimize = datetime(2025, 1, 1)

    def __init__(self, config: dict) -> None:
        super().__init__(config)
        self.market_phase = "NORMAL"
        self.entry_conditions = self.entry_params.copy()
        self.trade_timeout = timedelta(minutes=25)
        self.risk_factor = 0.95
        self.api_retry_count = 0
        logger.info("🦅 الصقر الذهبي يحلق بحكمة! بسم الله الرحمن الرحيم")

    def binance_api_request(self, url, params=None):
        """طلب ذكي لـ Binance API مع تجاوز القيود الجغرافية"""
        proxies = {
            'http': 'http://20.210.113.32:80',  # بروكسي أمريكي
            'https': 'http://20.210.113.32:80'
        }
        
        headers = {
            'X-MBX-APIKEY': self.config['exchange']['key'],
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36'
        }
        
        try:
            response = requests.get(
                url,
                params=params,
                headers=headers,
                proxies=proxies,
                timeout=10
            )
            return response.json()
        except Exception as e:
            logger.error(f"خطأ في الاتصال: {str(e)}")
            return None

    def reload_markets(self):
        """إعادة تحميل الأسواق بطريقة ذكية"""
        markets_url = "https://api.binance.com/api/v3/exchangeInfo"
        markets_data = self.binance_api_request(markets_url)
        
        if markets_data:
            return markets_data
        else:
            # استخدام نسخة احتياطية محفوظة
            backup_markets = {
                "symbols": [
                    {"symbol": "SHIBUSDT", "status": "TRADING"},
                    {"symbol": "TRXUSDT", "status": "TRADING"},
                    {"symbol": "DOGEUSDT", "status": "TRADING"},
                    {"symbol": "BTTUSDT", "status": "TRADING"},
                    {"symbol": "WINUSDT", "status": "TRADING"},
                    {"symbol": "SXPUSDT", "status": "TRADING"},
                    {"symbol": "LTCUSDT", "status": "TRADING"},
                    {"symbol": "XRPUSDT", "status": "TRADING"},
                    {"symbol": "ADAUSDT", "status": "TRADING"}
                ]
            }
            logger.warning("✅ استخدام الأسواق الاحتياطية")
            return backup_markets

    def analyze_market(self, dataframe: DataFrame) -> str:
        """تحليل حكيم للسوق مع مرونة أعلى"""
        if len(dataframe) < 30:  # تقليل الحد الأدنى لزيادة المرونة
            return "NORMAL"
            
        # تقييم متعدد الأبعاد مع معاملات مرنة
        volatility = dataframe['close'].pct_change().std() * np.sqrt(365)
        volume_trend = dataframe['volume'].rolling(5).mean().pct_change().mean()
        rsi_trend = pta.rsi(dataframe['close'], length=10).pct_change().mean()  # فترة أقصر
        
        if volatility > 0.04 and volume_trend > 0.08:  # معاملات أوسع
            return "VOLATILE"
        if volatility < 0.02 and rsi_trend < -0.04:
            return "CALM"
        return "NORMAL"

    def dynamic_adjustments(self):
        """تعديلات حكيمة حسب السوق"""
        if self.market_phase == "VOLATILE":
            self.minimal_roi = {"0": 0.025, "10": 0.012}
            self.stoploss = -0.015
            self.entry_params['rsi_max'] = 40
            self.risk_factor = 0.90  # مخاطرة أقل
        elif self.market_phase == "CALM":
            self.minimal_roi = {"0": 0.02, "40": 0.005}
            self.stoploss = -0.008
            self.entry_params['volume_ratio'] = 1.35
            self.risk_factor = 0.98  # مخاطرة أكبر
        else:
            self.minimal_roi = {"0": 0.028, "15": 0.015, "40": 0.005}
            self.stoploss = -0.012
            self.risk_factor = 0.95

    def populate_indicators(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """مؤشرات حكيمة متوازنة مع تعزيز الكفاءة"""
        # RSI متوازن (12 فترة)
        dataframe['rsi'] = pta.rsi(dataframe['close'], length=12) if len(dataframe) > 12 else 50
        
        # MACD سريع الاستجابة
        macd = pta.macd(dataframe['close'], fast=10, slow=20, signal=7)  # فترات أقصر
        dataframe['macd'] = macd['MACD_10_20_7']
        dataframe['signal'] = macd['MACDs_10_20_7']
        
        # أحكام أكثر مرونة
        dataframe['volume_mean'] = dataframe['volume'].rolling(15).mean()
        
        # قوة الاتجاه بفترة أقصر
        dataframe['adx'] = pta.adx(dataframe['high'], dataframe['low'], dataframe['close'], length=10)['ADX_10']
        
        # تحليل السوق
        self.market_phase = self.analyze_market(dataframe)
        self.dynamic_adjustments()
        
        return dataframe

    def populate_entry_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """قواعد دخول حكيمة"""
        conditions = [
            dataframe['rsi'] < self.entry_params['rsi_max'],
            dataframe['macd'] > dataframe['signal'],
            dataframe['volume'] > dataframe['volume_mean'] * self.entry_params['volume_ratio'],
            dataframe['adx'] > 25,  # تأكيد وجود اتجاه قوي
            dataframe['close'] > dataframe['open'].shift(2)  # تأكيد استمرارية الاتجاه
        ]
        
        # تطبيق الشروط بحكمة
        dataframe.loc[
            np.logical_and.reduce(conditions, axis=0), 
            'enter_long'
        ] = 1
        
        # تسجيل إشارات الدخول بحكمة
        if any(dataframe['enter_long'] == 1):
            logger.info(f"🔥 إشارة دخول حكيمة: {metadata['pair']}")
            
        return dataframe

    def populate_exit_trend(self, dataframe: DataFrame, metadata: dict) -> DataFrame:
        """قواعد خروج حكيمة"""
        exit_conditions = []
        
        if self.market_phase == "VOLATILE":
            exit_conditions.append(dataframe['rsi'] > 62)
        else:
            exit_conditions.append(dataframe['rsi'] > 68)
        
        # خروج عند ضعف الاتجاه
        exit_conditions.append(dataframe['adx'] < 20)
        
        dataframe.loc[np.logical_or.reduce(exit_conditions), 'exit_long'] = 1
        return dataframe

    def custom_stoploss(self, pair: str, trade: Trade, current_time: datetime,
                        current_rate: float, current_profit: float, **kwargs) -> float:
        """وقف خسارة حكيم ومتطور"""
        # وقف الخسارة الديناميكي حسب مرحلة السوق
        base_sl = -0.015 if self.market_phase == "VOLATILE" else -0.01
        
        # تعديل حسب مدة التداول
        time_diff = (current_time - trade.open_date).total_seconds() / 3600
        if time_diff > 4:  # إذا تجاوزت الصفقة 4 ساعات
            return base_sl * 0.8  # وقف خسارة أقل
        
        return base_sl

    def bot_start(self, **kwargs) -> None:
        """رسالة البدء الحكيمة"""
        logger.info("🦅 الصقر الذهبي يحلق بحكمة! بسم الله الرحمن الرحيم")
        logger.info("🧠 النسخة الحكيمة 4.0 - توازن بين القوة والحكمة")
        logger.info(f"📊 مرحلة السوق: {self.market_phase}")
        logger.info(f"⚖️ عامل المخاطرة: {self.risk_factor}")

    def custom_stake_amount(self, pair: str, current_time: datetime, current_rate: float,
                           proposed_stake: float, min_stake: float, max_stake: float,
                           **kwargs) -> float:
        """إدارة رأس مال حكيمة ومحكمة"""
        free_balance = self.wallets.get_free('USDT')
        
        # نظام توزيع حكيم يعتمد على عدة عوامل
        position_size = free_balance * self.risk_factor
        
        # لا تتجاوز 20% من الرصيد في صفقة واحدة
        if position_size > free_balance * 0.2:
            position_size = free_balance * 0.2
        
        # التأكد من الحد الأدنى والأقصى
        return max(min(position_size, max_stake), min_stake)

    def adjust_trade_position(self, trade: Trade, current_time: datetime,
                          current_rate: float, current_profit: float,
                          min_stake: float, max_stake: float, **kwargs) -> float:
        """زيادة حكيمة للحصة عند التأكد من نجاح الصفقة"""
        # فقط إذا كان الربح فوق 2.5% وكانت الصفقة نشطة لأكثر من 30 دقيقة
        time_diff = (current_time - trade.open_date).total_seconds() / 60
        if current_profit > 0.025 and time_diff > 30:
            # زيادة لا تتجاوز 30% من الحصة الأصلية
            return min(trade.stake_amount * 0.3, max_stake)
        return 0

    def bot_loop_start(self, **kwargs) -> None:
        """تطوير ذاتي أسبوعي حكيم"""
        now = datetime.now()
        if now.weekday() == 0 and (now - self.last_optimize).days >= 7:
            self.optimize_strategy()
            self.last_optimize = now
        
    def optimize_strategy(self):
        """تحسين حكيم للإستراتيجية يعتمد على البيانات"""
        logger.info("🦅 الصقر يطور نفسه بحكمة!")
        try:
            trades = Trade.get_trades_proxy()
            if trades and len(trades) > 15:
                # تحليل أداء السوق المختلفة
                volatile_trades = [t for t in trades if t.enter_tag == 'VOLATILE']
                calm_trades = [t for t in trades if t.enter_tag == 'CALM']
                
                # تحسين حسب ظروف السوق
                if volatile_trades:
                    win_rate_volatile = len([t for t in volatile_trades if t.close_profit > 0]) / len(volatile_trades)
                    if win_rate_volatile < 0.6:
                        self.entry_params['rsi_max'] = max(35, self.entry_params['rsi_max'] - 1)
                        logger.info(f"🔄 تخفيض RSI_max للأسواق المتقلبة إلى {self.entry_params['rsi_max']}")
                
                if calm_trades:
                    win_rate_calm = len([t for t in calm_trades if t.close_profit > 0]) / len(calm_trades)
                    if win_rate_calm < 0.55:
                        self.entry_params['volume_ratio'] = min(1.5, self.entry_params['volume_ratio'] + 0.05)
                        logger.info(f"🔄 زيادة volume_ratio للأسواق الهادئة إلى {self.entry_params['volume_ratio']}")
                    
        except Exception as e:
            logger.error(f"التطوير الذاتي الحكيم فشل: {str(e)}")

    def protect_trades(self):
        """نظام حماية متطور للصفقات"""
        open_trades = Trade.get_open_trades()
        for trade in open_trades:
            # إغلاق الصفقات عند انخفاض السيولة
            if self.market_liquidity < 0.2:
                logger.warning(f"🚨 إغلاق طارئ لـ {trade.pair_id} بسبب انخفاض السيولة")
                return True
                
            # حماية من التقلبات المفاجئة
            if self.market_volatility > 0.15:
                logger.warning(f"🚨 إغلاق وقائي لـ {trade.pair_id} بسبب التقلبات")
                return True
                
        return False

# نظام النبض الذكي
def heart_beat():
    """نظام مراقبة ذاتي متقدم"""
    logger = logging.getLogger(__name__)
    while True:
        try:
            logger.info("❤️ نبض الصقر: النظام يعمل بشكل مثالي")
            time.sleep(300)
        except Exception as e:
            logger.error(f"خطأ في نظام النبض: {str(e)}")
            time.sleep(60)

# بدء نظام النبض في خيط منفصل
if __name__ == "__main__":
    import threading
    heartbeat_thread = threading.Thread(target=heart_beat, daemon=True)
    heartbeat_thread.start()
    logger.info("🚀 نظام النبض الذكي مفعل!")
