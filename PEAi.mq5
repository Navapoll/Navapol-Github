//+------------------------------------------------------------------+
//|                                                         PEAi.mq5 |
//| PEAi By Rattana (v5.42 Refactored)                               |
//+------------------------------------------------------------------+
#property copyright "PEAi 🤖"
#property version "5.42"
#property indicator_separate_window
#property indicator_buffers 47
#property indicator_plots 6

#include <PEAi_GUI.mqh> // Include GUI Library

// --- Plot Settings ---
#property indicator_label1 "Val Histogram"
#property indicator_type1 DRAW_COLOR_HISTOGRAM
#property indicator_color1 clrBlack, clrRed
#property indicator_width1 4
#property indicator_style1 STYLE_SOLID

#property indicator_label2 "Val 5"
#property indicator_type2 DRAW_COLOR_LINE
#property indicator_color2 clrBlack, clrRed
#property indicator_width2 1
#property indicator_style2 STYLE_SOLID

#property indicator_label3 "Val 10"
#property indicator_type3 DRAW_COLOR_LINE
#property indicator_color3 clrBlack, clrRed
#property indicator_width3 1
#property indicator_style3 STYLE_SOLID

#property indicator_label4 "Val 15"
#property indicator_type4 DRAW_COLOR_LINE
#property indicator_color4 clrBlack, clrRed
#property indicator_width4 2
#property indicator_style4 STYLE_SOLID

#property indicator_label5 "Val 20"
#property indicator_type5 DRAW_COLOR_LINE
#property indicator_color5 clrBlack, clrRed
#property indicator_width5 2
#property indicator_style5 STYLE_SOLID

#property indicator_label6 "Price EMA Data"
#property indicator_type6 DRAW_NONE

// ==========================================
// 1. INPUTS
// ==========================================
input int InpKCLogic = 12;
input int InpVoteStart = 2;
input int InpVoteEnd = 19;
input bool InpValCheck = false;

input bool InpUseAtLeast = true;
input int InpThreshold = 2;
input int InpLenRun = 2;
input bool InpUseShortAtLeast = false;
input int InpShortThreshold = 99;

input bool InpUseAbnormal = true;
input int InpAbnormalLen = 10;
input double InpAbnormalMult1 = 1.0;

input double InpMinThreshold = 0.5;
input double InpMaxThreshold = 3.0;
input int InpDeltaLen = 10; 

input int InpLengthKC = 20;

input bool InpShowPriceEMA = true;
input int InpPriceEMAPeriod1 = 22;
input int InpPriceEMAPeriod2 = 55;
input int InpPriceEMAPeriod3 = 188;

input bool InpUseTime = true;
input int InpTimeOffset = 5;
input int InpTimeStart1 = 14;
input int InpTimeStop1 = 24;
input int InpTimeStart2 = 0;
input int InpTimeStop2 = 0;
input bool InpTradeMon = true;
input bool InpTradeTue = true;
input bool InpTradeWed = true;
input bool InpTradeThu = true;
input bool InpTradeFri = true;
input bool InpTradeSat = true;
input bool InpTradeSun = true;

input bool InpUseNewsFilter = true;
input int InpNewsBefore = 10;
input int InpNewsAfter = 10;
input bool InpNewsHigh = true;
input bool InpNewsMedium = false;

input double InpBalance = 0; 
input int InpSpread = 0;
input double InpTPRatio = 1.0;

input string ___Risk_Settings___ = "=== RISK SETTINGS ===";
input ENUM_RISK_MODE InpRiskMode = RISK_MODE_MONEY;
input double InpRisk = 1.0;      
input double InpRiskMoney = 55.0; 
input double InpFixedLot = 0.01;  

input int InpLeverage = 0;
input int InpSWCount = 10; 
input int InpSLPadding = 30;
input int InpBarPlot = 15;
input bool InpShowRealtime = true;
input bool InpDrawSignalLines = true;

input bool InpShowDashboard = true;
input int InpDashX = 20;
input int InpDashY = 40;
input bool InpAlertPopUp = true;
input bool InpAlertPush = true;
input double InpArrowGapMult = 1.0;
input int InpMaxBars = 1000;
input int InpMaxBarsVisual = 1000;
input int InpLinkEAMagic = 88888888; 

// ==========================================
// 2. BUFFERS & GLOBALS
// ==========================================
double BufferVal[], BufferValColor[];
double BufferVal5[], BufferVal5Color[];
double BufferVal10[], BufferVal10Color[];
double BufferVal15[], BufferVal15Color[];
double BufferVal20[], BufferVal20Color[];
double BufferEMA1[], BufferEMA2[], BufferEMA3[];

double BufferLogBuy[], BufferLogSell[];
double BufferRunB[], BufferRunS[];
double BufferShortRunB[], BufferShortRunS[];
double BufferDelta[], BufferAbnormal[];
double BufferSigStateBuy[], BufferSigStateSell[];
double BufferSigBuyFlag[], BufferSigSellFlag[];
double BufferWaitBuyFlag[], BufferWaitSellFlag[];
double BufferSlowDownBase[], BufferSlowUpBase[];

double BufferSigState[], BufferSendLot[], BufferSendTP[], BufferSendSL[];
double BufferMB_Lot[], BufferMB_TP[], BufferMB_SL[];
double BufferMS_Lot[], BufferMS_TP[], BufferMS_SL[];

double BufferSemiSlowDown[], BufferSemiSlowUp[];
double BufferSlowDown1[], BufferSlowUp1[];

double BufferVoteBuy[], BufferVoteSell[], BufferBaseRange[];
double BufferTimeFilter[];

double G_PrefixSum[];

int GlobalWins = 0;
int GlobalLosses = 0;
int GlobalPending = 0;
double GlobalNetProfit = 0.0;

// Stats Globals
double GlobalSumLossIntensity = 0.0;
double GlobalSumLossVal = 0.0;
long GlobalSumLossVotes = 0;
int GlobalLossCountStats = 0;

double GlobalSumWinIntensity = 0.0;
double GlobalSumWinVal = 0.0;
long GlobalSumWinVotes = 0;
int GlobalWinCountStats = 0;

string Prefix = "PEAi_Dash_";
string ObjPrefix = "PEAi_Arr_";
string RT_Prefix = "PEAi_RT_";
string TradePrefix = "PEAi_Trade_";
string EMAPrefix = "PEAi_EMA_";
string InstanceID;

// ==========================================
// GLOBAL BRIDGE VARIABLES
// ==========================================
int G_BuyCount = 0, G_SellCount = 0;
bool G_IsAbnormal = false, G_IsTimeAllowed = true, G_NewsBlock = false;
double G_Intensity = 0, G_Delta = 0, G_Delta1 = 0;
double G_BaseRange = 0.0;
bool G_FinalBBB = false, G_FinalSSS = false, G_FinalSigB = false, G_FinalSigS = false;
bool G_SemiDown = false, G_SemiUp = false;
double G_AvgLoss = 0, G_AvgWin = 0;
bool G_IsDashMinimized = false;
int G_RunB = 0, G_RunS = 0; 

// CSV Settings
int file_handle = INVALID_HANDLE;
string file_name = "PEAi_Backtest_Result.csv";

int OnInit() {
  SetIndexBuffer(0, BufferVal, INDICATOR_DATA);
  SetIndexBuffer(1, BufferValColor, INDICATOR_COLOR_INDEX);
  SetIndexBuffer(2, BufferVal5, INDICATOR_DATA);
  SetIndexBuffer(3, BufferVal5Color, INDICATOR_COLOR_INDEX);
  SetIndexBuffer(4, BufferVal10, INDICATOR_DATA);
  SetIndexBuffer(5, BufferVal10Color, INDICATOR_COLOR_INDEX);
  SetIndexBuffer(6, BufferVal15, INDICATOR_DATA);
  SetIndexBuffer(7, BufferVal15Color, INDICATOR_COLOR_INDEX);
  SetIndexBuffer(8, BufferVal20, INDICATOR_DATA);
  SetIndexBuffer(9, BufferVal20Color, INDICATOR_COLOR_INDEX);
  SetIndexBuffer(10, BufferEMA1, INDICATOR_DATA);

  SetIndexBuffer(11, BufferLogBuy, INDICATOR_CALCULATIONS);
  SetIndexBuffer(12, BufferLogSell, INDICATOR_CALCULATIONS);
  SetIndexBuffer(13, BufferRunB, INDICATOR_CALCULATIONS);
  SetIndexBuffer(14, BufferRunS, INDICATOR_CALCULATIONS);
  SetIndexBuffer(15, BufferShortRunB, INDICATOR_CALCULATIONS);
  SetIndexBuffer(16, BufferShortRunS, INDICATOR_CALCULATIONS);
  SetIndexBuffer(17, BufferDelta, INDICATOR_CALCULATIONS);
  SetIndexBuffer(18, BufferAbnormal, INDICATOR_CALCULATIONS);
  SetIndexBuffer(19, BufferSigStateBuy, INDICATOR_CALCULATIONS);
  SetIndexBuffer(20, BufferSigStateSell, INDICATOR_CALCULATIONS);
  SetIndexBuffer(21, BufferSigBuyFlag, INDICATOR_CALCULATIONS);
  SetIndexBuffer(22, BufferSigSellFlag, INDICATOR_CALCULATIONS);
  SetIndexBuffer(23, BufferWaitBuyFlag, INDICATOR_CALCULATIONS);
  SetIndexBuffer(24, BufferWaitSellFlag, INDICATOR_CALCULATIONS);
  SetIndexBuffer(25, BufferSlowDownBase, INDICATOR_CALCULATIONS);
  SetIndexBuffer(26, BufferSlowUpBase, INDICATOR_CALCULATIONS);
  SetIndexBuffer(27, BufferEMA2, INDICATOR_CALCULATIONS);
  SetIndexBuffer(28, BufferEMA3, INDICATOR_CALCULATIONS);

  SetIndexBuffer(29, BufferSigState, INDICATOR_CALCULATIONS);
  SetIndexBuffer(30, BufferSendLot, INDICATOR_CALCULATIONS);
  SetIndexBuffer(31, BufferSendTP, INDICATOR_CALCULATIONS);
  SetIndexBuffer(32, BufferSendSL, INDICATOR_CALCULATIONS);

  SetIndexBuffer(33, BufferMB_Lot, INDICATOR_CALCULATIONS);
  SetIndexBuffer(34, BufferMB_TP, INDICATOR_CALCULATIONS);
  SetIndexBuffer(35, BufferMB_SL, INDICATOR_CALCULATIONS);
  SetIndexBuffer(36, BufferMS_Lot, INDICATOR_CALCULATIONS);
  SetIndexBuffer(37, BufferMS_TP, INDICATOR_CALCULATIONS);
  SetIndexBuffer(38, BufferMS_SL, INDICATOR_CALCULATIONS);

  SetIndexBuffer(39, BufferSemiSlowDown, INDICATOR_CALCULATIONS);
  SetIndexBuffer(40, BufferSemiSlowUp, INDICATOR_CALCULATIONS);
  SetIndexBuffer(41, BufferSlowDown1, INDICATOR_CALCULATIONS);
  SetIndexBuffer(42, BufferSlowUp1, INDICATOR_CALCULATIONS);
  SetIndexBuffer(43, BufferVoteBuy, INDICATOR_CALCULATIONS);
  SetIndexBuffer(44, BufferVoteSell, INDICATOR_CALCULATIONS);
  SetIndexBuffer(45, BufferBaseRange, INDICATOR_CALCULATIONS);
  SetIndexBuffer(46, BufferTimeFilter, INDICATOR_CALCULATIONS);

  MathSrand(GetTickCount());
  InstanceID = IntegerToString(MathRand());
  Prefix = "PEAi_" + InstanceID + "_";
  ObjPrefix = Prefix + "Obj_";
  RT_Prefix = Prefix + "RT_";
  TradePrefix = Prefix + "Trd_";
  EMAPrefix = Prefix + "EMA_";

  if (InpBalance > 0) {
    file_handle = FileOpen(file_name, FILE_CSV | FILE_WRITE | FILE_ANSI | FILE_COMMON, ",");
    if (file_handle != INVALID_HANDLE) {
      FileWrite(file_handle, "Result", "Type", "Day", "Date", "Time_Thai",
                "Int", "Int_1", "Val", "Val_1", "Val_2", "Val_3", "Delta",
                "Delta_1", "Vote", "RunShort", "BaseRange", "BaseRange_1",
                "Abn_Threshold", "Abn_Threshold_1", "Is_Abn", "Is_Abn_1",
                "SL_Point", "Dur_Bars", "EMA_Dist", "EMA_Trend", "Body_Pct",
                "Spread");
    }
  }

  EventSetTimer(1);
  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  EventKillTimer();
  if (file_handle != INVALID_HANDLE) FileClose(file_handle);
  ObjectsDeleteAll(0, Prefix);
  Comment("");
  ChartRedraw(0);
}

void OnTimer() {
  string gvName = "PEAi_MIN_" + IntegerToString(InpLinkEAMagic);
  if (GlobalVariableCheck(gvName)) {
    bool eaIsMinimized = (GlobalVariableGet(gvName) == 1.0);
    if (G_IsDashMinimized != eaIsMinimized) {
      G_IsDashMinimized = eaIsMinimized;
    }
  }

  string rModeStr = "";
  if (InpRiskMode == RISK_MODE_FIXED_LOT) rModeStr = "FixLot: " + DoubleToString(InpFixedLot, 2);
  else if (InpRiskMode == RISK_MODE_MONEY) rModeStr = "Risk: $" + DoubleToString(InpRiskMoney, 0);
  else rModeStr = "Risk: " + DoubleToString(InpRisk, 1) + "%";

  CPEAi_Dashboard::Update(Prefix, G_IsDashMinimized, InpShowDashboard, InpDashX, InpDashY,
                          G_BuyCount, G_SellCount, G_IsAbnormal, G_IsTimeAllowed,
                          G_Intensity, G_Delta, G_Delta1, G_FinalBBB, G_FinalSSS,
                          G_FinalSigB, G_FinalSigS, G_SemiDown, G_SemiUp, G_NewsBlock,
                          G_BaseRange, _Symbol, _Period,
                          (InpBalance > 0 ? InpBalance : 0), GlobalNetProfit, GlobalWins, GlobalLosses,
                          rModeStr, G_RunB, G_RunS); 
  ChartRedraw(0);
}

// --- HELPER FUNCTION FOR DAY NAME ---
string GetDayName(int d) {
   switch(d) {
      case 0: return "Sun";
      case 1: return "Mon";
      case 2: return "Tue";
      case 3: return "Wed";
      case 4: return "Thu";
      case 5: return "Fri";
      case 6: return "Sat";
      default: return "";
   }
}

// --- MATH & LOGIC FUNCTIONS ---
double GetSMA(int pos, int len, const double &price[]) {
  if (pos + len > ArraySize(price)) return 0.0;
  double sum = 0;
  for (int i = 0; i < len; i++) sum += price[pos + i];
  return sum / len;
}

double GetSMA_Fast(int pos, int len, int total_bars) {
  if (pos + len >= total_bars) return 0.0;
  double sum = G_PrefixSum[pos] - G_PrefixSum[pos + len];
  return sum / len;
}

double GetPineSource(int pos, int len, const double &h[], const double &l[], const double &c[]) {
  int max_bars = ArraySize(c);
  if (pos + len > max_bars) return 0.0;
  int h_idx = ArrayMaximum(h, pos, len);
  int l_idx = ArrayMinimum(l, pos, len);
  double hh = h[h_idx];
  double ll = l[l_idx];
  double sma = GetSMA_Fast(pos, len, max_bars);
  return c[pos] - ((hh + ll) / 2.0 + sma) / 2.0;
}

double GetLinRegVal(int pos, int len, const double &h[], const double &l[], const double &c[]) {
  if (pos + len * 2 > ArraySize(c)) return 0.0;
  double SumY = 0, Sum1 = 0;
  for (int x = 0; x < len; x++) {
    double src = GetPineSource(pos + (len - 1 - x), len, h, l, c);
    SumY += src;
    Sum1 += x * src;
  }
  double p = (double)len;
  double SumBars = p * (p - 1) * 0.5;
  double SumSqrBars = (p - 1) * p * (2 * p - 1) / 6.0;
  double Num1 = p * Sum1 - SumBars * SumY;
  double Num2 = p * SumSqrBars - SumBars * SumBars;
  double Slope = (Num2 != 0) ? Num1 / Num2 : 0;
  double Intercept = (SumY - Slope * SumBars) / p;
  return Intercept + Slope * (p - 1);
}

double GetStDevCustom(int pos, int len, const double &buffer[]) {
  if (pos + len > ArraySize(buffer)) return 0.0;
  double sum = 0;
  for (int i = 0; i < len; i++) sum += buffer[pos + i];
  double avg = sum / len;
  double sum_sq = 0;
  for (int i = 0; i < len; i++) sum_sq += MathPow(buffer[pos + i] - avg, 2);
  return MathSqrt(sum_sq / len);
}

double GetDynamicWaveStDev(int pos, int max_lookback, const double &delta_buf[], const double &val_buf[], bool check_down_trend) {
  double sum = 0;
  double sum_sq = 0;
  int count = 0;
  for (int k = 0; k < max_lookback; k++) {
    if (pos + k + 1 >= ArraySize(val_buf)) break;
    bool is_consistent = false;
    if (check_down_trend) {
      if (val_buf[pos + k] <= val_buf[pos + k + 1]) is_consistent = true;
    } else {
      if (val_buf[pos + k] >= val_buf[pos + k + 1]) is_consistent = true;
    }
    if (!is_consistent) break;
    double d = delta_buf[pos + k];
    sum += d;
    sum_sq += MathPow(d, 2);
    count++;
  }
  if (count < 3) return 1.0;
  double avg = sum / count;
  double var = (sum_sq / count) - (avg * avg);
  return MathSqrt(var > 0 ? var : 0);
}

double GetDynamicSwingPrice(int pos, int max_lookback, const double &h[], const double &l[], const double &val[], bool isBuy) {
  double extremePrice = isBuy ? l[pos] : h[pos];
  int bars_searched = 0;
  bool wave_is_up = val[pos] >= val[pos + 1];
  for (int k = 0; k < max_lookback; k++) {
    int idx = pos + k;
    int next_idx = pos + k + 1;
    if (next_idx >= ArraySize(val)) break;
    double v_curr = val[idx];
    double v_prev = val[next_idx];
    bool is_consistent = false;
    if (wave_is_up) {
      if (v_curr >= v_prev) is_consistent = true;
    } else {
      if (v_curr <= v_prev) is_consistent = true;
    }
    if (!is_consistent) break;
    if (isBuy) {
      if (l[idx] < extremePrice) extremePrice = l[idx];
    } else {
      if (h[idx] > extremePrice) extremePrice = h[idx];
    }
    bars_searched++;
  }
  if (bars_searched < 3) {
    for (int k = 0; k < 5; k++) {
      int idx = pos + k;
      if (idx >= ArraySize(val)) break;
      if (isBuy) {
        if (l[idx] < extremePrice) extremePrice = l[idx];
      } else {
        if (h[idx] > extremePrice) extremePrice = h[idx];
      }
    }
  }
  return extremePrice;
}

bool IsSmallBody(int idx, const double &h[], const double &l[], const double &o[], const double &c[]) {
  double r = h[idx] - l[idx];
  double b = MathAbs(c[idx] - o[idx]);
  return r == 0 ? true : (b / r) < 0.1;
}

double GetValColorIndex(double curr, double prev) {
  if (curr > 0) return (curr > prev) ? 0.0 : 1.0;
  else return (curr < prev) ? 1.0 : 0.0;
}

bool IsHolidaySeason(datetime time) {
  if (!InpUseNewsFilter) return false;
  MqlDateTime dt;
  TimeToStruct(time, dt);
  if (dt.mon == 12 && dt.day >= 15) return true;
  if (dt.mon == 1 && dt.day <= 5) return true;
  return false;
}

bool CheckTimeFilter(datetime currentTime) {
  if (!InpUseTime) return true;
  MqlDateTime dt;
  TimeToStruct(currentTime + InpTimeOffset * 3600, dt);
  bool hOk = (dt.hour >= InpTimeStart1 && dt.hour < InpTimeStop1) || (dt.hour >= InpTimeStart2 && dt.hour < InpTimeStop2) || (dt.hour >= 14 && dt.hour < 15);
  bool dOk = false;
  switch (dt.day_of_week) {
  case 0: dOk = InpTradeSun; break;
  case 1: dOk = InpTradeMon; break;
  case 2: dOk = InpTradeTue; break;
  case 3: dOk = InpTradeWed; break;
  case 4: dOk = InpTradeThu; break;
  case 5: dOk = InpTradeFri; break;
  case 6: dOk = InpTradeSat; break;
  }
  return hOk && dOk;
}

bool HasNews(string currency, datetime t1, datetime t2) {
  MqlCalendarValue values[];
  if (CalendarValueHistory(values, t1, t2, NULL, currency)) {
    for (int i = 0; i < ArraySize(values); i++) {
      MqlCalendarEvent event;
      if (CalendarEventById(values[i].event_id, event)) {
        if (InpNewsHigh && event.importance == CALENDAR_IMPORTANCE_HIGH) return true;
        if (InpNewsMedium && event.importance == CALENDAR_IMPORTANCE_MODERATE) return true;
      }
    }
  }
  return false;
}

bool IsNewsBlocking(datetime currentTime) {
  if (!InpUseNewsFilter) return false;
  static datetime lastCheck = 0;
  static bool lastResult = false;
  if (currentTime < lastCheck + 60 && currentTime >= lastCheck) return lastResult;
  lastCheck = currentTime;
  lastResult = false;
  string base = SymbolInfoString(_Symbol, SYMBOL_CURRENCY_BASE);
  string quote = SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT);
  datetime t1 = currentTime - InpNewsAfter * 60;
  datetime t2 = currentTime + InpNewsBefore * 60;
  if (HasNews(base, t1, t2)) lastResult = true;
  else if (HasNews(quote, t1, t2)) lastResult = true;
  return lastResult;
}

int GetTradeOutcome(int startIdx, bool isBuy, double entry, double sl, double tp, const double &high[], const double &low[], int &endIdx) {
  int barsChecked = 0;
  for (int k = startIdx - 1; k >= 0; k--) {
    barsChecked++;
    if (isBuy) {
      if (low[k] <= sl) { endIdx = k; return -1; }
      if (high[k] >= tp) { endIdx = k; return 1; }
    } else {
      if (high[k] >= sl) { endIdx = k; return -1; }
      if (low[k] <= tp) { endIdx = k; return 1; }
    }
    if (barsChecked > 500) { endIdx = k; return 0; }
  }
  endIdx = 0;
  return 0;
}

double CalculateProfitUSD(int outcome, double riskMoney) {
  if (outcome == 1) return riskMoney * InpTPRatio;
  if (outcome == -1) return -riskMoney;
  return 0.0;
}

double VerifyVolume(double lot) {
  double min_vol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
  double max_vol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
  double step_vol = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
  if (step_vol > 0) lot = MathFloor(lot / step_vol) * step_vol;
  if (lot < min_vol) lot = min_vol;
  if (lot > max_vol) lot = max_vol;
  return NormalizeDouble(lot, 2);
}

double GetBaseRangeValue(int i, int rates_total, const double &o[], const double &c[], const double &val[]) {
  double sum = 0;
  int count = 0;
  if (InpAbnormalLen > 0) {
    for (int k = 0; k < InpAbnormalLen; k++) {
      if (i + k + 1 >= rates_total) break;
      double body = MathAbs(c[i + k + 1] - o[i + k + 1]);
      sum += body;
      count++;
    }
  } else {
    if (i + 2 >= rates_total) return 0.0;
    bool wave_is_up = val[i + 1] >= val[i + 2];
    int max_lookback = 100;
    for (int k = 1; k < max_lookback; k++) {
      int idx = i + k;
      int next_idx = i + k + 1;
      if (next_idx >= ArraySize(val)) break;
      double v_curr = val[idx];
      double v_prev = val[next_idx];
      bool is_consistent = false;
      if (wave_is_up) {
        if (v_curr >= v_prev) is_consistent = true;
      } else {
        if (v_curr <= v_prev) is_consistent = true;
      }
      if (!is_consistent) break;
      double body = MathAbs(c[idx] - o[idx]);
      sum += body;
      count++;
    }
    if (count < 3) {
      sum = 0; count = 0;
      for (int x = 1; x <= 5; x++) {
        if (i + x < rates_total) {
          sum += MathAbs(c[i + x] - o[i + x]);
          count++;
        }
      }
    }
  }
  return (count > 0) ? (sum / count) : 0.0;
}

double GetAbnormalThresholdFixed(int i, int rates_total, const double &o[], const double &c[]) {
  double sum = 0;
  double sum_sq = 0;
  for (int k = 0; k < InpAbnormalLen; k++) {
    if (i + k >= rates_total) break;
    double body = MathAbs(c[i + k] - o[i + k]);
    sum += body;
    sum_sq += body * body;
  }
  double range_avg = sum / InpAbnormalLen;
  double var = (sum_sq / InpAbnormalLen) - (range_avg * range_avg);
  double range_std = MathSqrt(var > 0 ? var : 0);
  return (range_avg + (InpAbnormalMult1 * range_std));
}

double GetAbnormalThresholdDynamic(int pos, int rates_total, const double &o[], const double &c[], const double &val[], double mult) {
  bool wave_is_up = val[pos] >= val[pos + 1];
  double sum = 0;
  double sum_sq = 0;
  int count = 0;
  int max_lookback = 100;
  for (int k = 1; k < max_lookback; k++) {
    int idx = pos + k;
    int next_idx = pos + k + 1;
    if (next_idx >= rates_total) break;
    double v_curr = val[idx];
    double v_prev = val[next_idx];
    bool is_consistent = false;
    if (wave_is_up) {
      if (v_curr >= v_prev) is_consistent = true;
    } else {
      if (v_curr <= v_prev) is_consistent = true;
    }
    if (!is_consistent) break;
    double body = MathAbs(c[idx] - o[idx]);
    sum += body;
    sum_sq += body * body;
    count++;
  }
  if (count < 5) return 999999.0;
  double mean = sum / count;
  double var = (sum_sq / count) - (mean * mean);
  double stdev = MathSqrt(var > 0 ? var : 0);
  return (mean + (mult * stdev));
}

void UpdateRealtimeTPSL(const double &high[], const double &low[], const double &close[], const datetime &time[]) {
  if (!InpShowRealtime) return;

  int idxH = ArrayMaximum(high, 0, InpSWCount > 0 ? InpSWCount : 10);
  int idxL = ArrayMinimum(low, 0, InpSWCount > 0 ? InpSWCount : 10);
  double sH = high[idxH];
  double sL = low[idxL];
  datetime tH = time[idxH];
  datetime tL = time[idxL];
  double cls = close[0];
  double padding = InpSLPadding * _Point;
  double sl_level_buy_bid = sL - padding;
  double sl_level_sell_bid_view = sH + padding;
  double calcBalance = (InpBalance > 0) ? InpBalance : AccountInfoDouble(ACCOUNT_BALANCE);
  double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
  double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
  double riskMoney = 0.0;
  if (InpRiskMode == RISK_MODE_MONEY) riskMoney = InpRiskMoney;
  else if (InpRiskMode == RISK_MODE_PERCENT) riskMoney = calcBalance * (InpRisk / 100.0);
  double spreadPoint = (InpSpread > 0) ? (double)InpSpread : (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
  double spreadVal = spreadPoint * _Point;
  double sl_level_sell_ask = sl_level_sell_bid_view + spreadVal;
  double distPriceB = (cls + spreadVal) - sl_level_buy_bid;
  double distTicksB = (distPriceB > 0) ? distPriceB / tickSize : 0;
  double calcLotB = 0;
  if (InpRiskMode == RISK_MODE_FIXED_LOT) calcLotB = InpFixedLot;
  else calcLotB = (distTicksB * tickValue > 0) ? riskMoney / (distTicksB * tickValue) : 0;
  double rewardB = distPriceB * InpTPRatio;
  double tpPriceB = (cls + spreadVal) + rewardB;
  double distPriceS = sl_level_sell_ask - cls;
  double distTicksS = (distPriceS > 0) ? distPriceS / tickSize : 0;
  double calcLotS = 0;
  if (InpRiskMode == RISK_MODE_FIXED_LOT) calcLotS = InpFixedLot;
  else calcLotS = (distTicksS * tickValue > 0) ? riskMoney / (distTicksS * tickValue) : 0;
  double rewardS = distPriceS * InpTPRatio;
  double tpPriceS_Ask = cls - rewardS;
  double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
  double accountLev = (double)AccountInfoInteger(ACCOUNT_LEVERAGE);
  double leverage = (InpLeverage > 0) ? (double)InpLeverage : (accountLev > 0 ? accountLev : 100);
  double maxLotLev = (cls > 0) ? (calcBalance * leverage) / (cls * contractSize) : 999;
  double finalLotB = 0, finalLotS = 0;
  if (InpRiskMode == RISK_MODE_FIXED_LOT) {
    finalLotB = InpFixedLot;
    finalLotS = InpFixedLot;
  } else {
    finalLotB = MathMin(MathMax(calcLotB, 0.01), maxLotLev);
    finalLotS = MathMin(MathMax(calcLotS, 0.01), maxLotLev);
  }
  finalLotB = VerifyVolume(finalLotB);
  finalLotS = VerifyVolume(finalLotS);
  BufferMB_Lot[0] = finalLotB;
  BufferMB_TP[0] = tpPriceB;
  BufferMB_SL[0] = sl_level_buy_bid;
  BufferMS_Lot[0] = finalLotS;
  BufferMS_TP[0] = tpPriceS_Ask;
  BufferMS_SL[0] = sl_level_sell_ask;
  double ptsS = (sl_level_sell_ask - cls) / _Point;
  double ptsB = ((cls + spreadVal) - sl_level_buy_bid) / _Point;
  int periodSec = PeriodSeconds();
  datetime endTime = time[0] + (InpBarPlot * periodSec);

  CPEAi_GUI::DrawTrendLine(RT_Prefix + "LS", tH, sl_level_sell_ask, endTime, sl_level_sell_ask, clrRed, 1);
  CPEAi_GUI::CreateLabel(RT_Prefix + "TxtS_Lot", 0, 0, StringFormat("%.2f Lot", finalLotS), 9, clrRed, false, ANCHOR_LEFT_LOWER);
  ObjectSetInteger(0, RT_Prefix + "TxtS_Lot", OBJPROP_TIME, endTime);
  ObjectSetDouble(0, RT_Prefix + "TxtS_Lot", OBJPROP_PRICE, sl_level_sell_ask);
  CPEAi_GUI::CreateLabel(RT_Prefix + "TxtS_Pts", 0, 0, StringFormat("%.0f Pts (Risk)", ptsS), 9, clrRed, false, ANCHOR_LEFT_UPPER);
  ObjectSetInteger(0, RT_Prefix + "TxtS_Pts", OBJPROP_TIME, endTime);
  ObjectSetDouble(0, RT_Prefix + "TxtS_Pts", OBJPROP_PRICE, sl_level_sell_ask);

  CPEAi_GUI::DrawTrendLine(RT_Prefix + "LB", tL, sl_level_buy_bid, endTime, sl_level_buy_bid, clrBlack, 1);
  CPEAi_GUI::CreateLabel(RT_Prefix + "TxtB_Lot", 0, 0, StringFormat("%.2f Lot", finalLotB), 9, clrBlack, false, ANCHOR_LEFT_LOWER);
  ObjectSetInteger(0, RT_Prefix + "TxtB_Lot", OBJPROP_TIME, endTime);
  ObjectSetDouble(0, RT_Prefix + "TxtB_Lot", OBJPROP_PRICE, sl_level_buy_bid);
  CPEAi_GUI::CreateLabel(RT_Prefix + "TxtB_Pts", 0, 0, StringFormat("%.0f Pts (Risk)", ptsB), 9, clrBlack, false, ANCHOR_LEFT_UPPER);
  ObjectSetInteger(0, RT_Prefix + "TxtB_Pts", OBJPROP_TIME, endTime);
  ObjectSetDouble(0, RT_Prefix + "TxtB_Pts", OBJPROP_PRICE, sl_level_buy_bid);
}

void DrawMainChartEMA(int i, int rates_total, const datetime &time[], const double &ema_buf[], int index, color col, int width) {
  if (i >= rates_total - 1) return;
  string name = EMAPrefix + IntegerToString(index) + "_" + IntegerToString((int)time[i]);
  if (ObjectFind(0, name) >= 0) {
    if (i == 0) ObjectSetDouble(0, name, OBJPROP_PRICE, 1, ema_buf[i]);
    return;
  }
  double p1 = ema_buf[i + 1];
  double p2 = ema_buf[i];
  if (p1 == 0 || p2 == 0) return;
  CPEAi_GUI::DrawTrendLine(name, time[i+1], p1, time[i], p2, col, width, false);
  ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
  ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
}

void ManageArrows(int i, int rates_total, const datetime &time[], const double &high[], const double &low[], const double &val[], bool finalsigB, bool finalsigS, bool finalBBB, bool finalSSS, bool isTimeAllowed, bool semi_is_slowing_up, bool semi_is_slowing_down) {
  if (!isTimeAllowed) return;
  double gap = 10 * _Point * InpArrowGapMult; 
  string timeStr = IntegerToString((int)time[i]);
  int subwin = ChartWindowFind();

  if (semi_is_slowing_down && finalsigB) {
     CPEAi_GUI::DrawArrow(ObjPrefix + "WB_" + timeStr, time[i], low[i] - gap, 241, clrBlack, 1, 0);
     CPEAi_GUI::DrawArrow(ObjPrefix + "Sub_WB_" + timeStr, time[i], val[i], 241, clrBlack, 1, subwin);
  } else {
     ObjectDelete(0, ObjPrefix + "WB_" + timeStr);
     ObjectDelete(0, ObjPrefix + "Sub_WB_" + timeStr);
  }
  
  if (semi_is_slowing_up && finalsigS) {
     CPEAi_GUI::DrawArrow(ObjPrefix + "WS_" + timeStr, time[i], high[i] + gap, 242, clrRed, 1, 0);
     CPEAi_GUI::DrawArrow(ObjPrefix + "Sub_WS_" + timeStr, time[i], val[i], 242, clrRed, 1, subwin);
  } else {
     ObjectDelete(0, ObjPrefix + "WS_" + timeStr);
     ObjectDelete(0, ObjPrefix + "Sub_WS_" + timeStr);
  }

  if (finalBBB) {
     CPEAi_GUI::DrawArrow(ObjPrefix + "B_" + timeStr, time[i], low[i] - gap * 1.5, 241, clrBlack, 4, 0);
     CPEAi_GUI::DrawArrow(ObjPrefix + "Sub_B_" + timeStr, time[i], val[i], 241, clrBlack, 4, subwin);
  } else {
     ObjectDelete(0, ObjPrefix + "B_" + timeStr);
     ObjectDelete(0, ObjPrefix + "Sub_B_" + timeStr);
  }

  if (finalSSS) {
     CPEAi_GUI::DrawArrow(ObjPrefix + "S_" + timeStr, time[i], high[i] + gap * 1.5, 242, clrRed, 4, 0);
     CPEAi_GUI::DrawArrow(ObjPrefix + "Sub_S_" + timeStr, time[i], val[i], 242, clrRed, 4, subwin);
  } else {
     ObjectDelete(0, ObjPrefix + "S_" + timeStr);
     ObjectDelete(0, ObjPrefix + "Sub_S_" + timeStr);
  }
}

void DrawSignalSetup(datetime time, double entry, double sl, double tp, bool isBuy, int outcome, int durationBars) {
  string pfx = TradePrefix + IntegerToString((int)time) + "_";
  int periodSec = PeriodSeconds();
  int plotLen = (durationBars > 0) ? durationBars : InpBarPlot;
  datetime endTime = time + (periodSec * plotLen);
  
  color colLine = (outcome == 1) ? clrLime : (outcome == -1 ? clrRed : clrGold);
  color colTP = (outcome == 1) ? clrLime : clrBlack;
  color colSL = (outcome == -1) ? clrRed : clrRed;
  int width = (outcome != 0) ? 2 : 1;

  CPEAi_GUI::DrawTrendLine(pfx + "En", time, entry, endTime, entry, colLine, width);
  CPEAi_GUI::DrawTrendLine(pfx + "SL", time, sl, endTime, sl, colSL, width);
  CPEAi_GUI::DrawTrendLine(pfx + "TP", time, tp, endTime, tp, colTP, width);
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[], const long &tick_volume[], const long &volume[], const int &spread[]) {
  if (rates_total < 200) return 0;
  ArraySetAsSeries(time, true); ArraySetAsSeries(high, true); ArraySetAsSeries(low, true); ArraySetAsSeries(close, true); ArraySetAsSeries(open, true); ArraySetAsSeries(spread, true);
  ArraySetAsSeries(BufferVal, true); ArraySetAsSeries(BufferValColor, true); ArraySetAsSeries(BufferVal5, true); ArraySetAsSeries(BufferVal5Color, true); ArraySetAsSeries(BufferVal10, true); ArraySetAsSeries(BufferVal10Color, true); ArraySetAsSeries(BufferVal15, true); ArraySetAsSeries(BufferVal15Color, true); ArraySetAsSeries(BufferVal20, true); ArraySetAsSeries(BufferVal20Color, true);
  ArraySetAsSeries(BufferEMA1, true); ArraySetAsSeries(BufferEMA2, true); ArraySetAsSeries(BufferEMA3, true);
  ArraySetAsSeries(BufferLogBuy, true); ArraySetAsSeries(BufferLogSell, true); ArraySetAsSeries(BufferRunB, true); ArraySetAsSeries(BufferRunS, true); ArraySetAsSeries(BufferShortRunB, true); ArraySetAsSeries(BufferShortRunS, true);
  ArraySetAsSeries(BufferDelta, true); ArraySetAsSeries(BufferAbnormal, true); ArraySetAsSeries(BufferSigStateBuy, true); ArraySetAsSeries(BufferSigStateSell, true);
  ArraySetAsSeries(BufferSigBuyFlag, true); ArraySetAsSeries(BufferSigSellFlag, true); ArraySetAsSeries(BufferWaitBuyFlag, true); ArraySetAsSeries(BufferWaitSellFlag, true);
  ArraySetAsSeries(BufferSlowDownBase, true); ArraySetAsSeries(BufferSlowUpBase, true); ArraySetAsSeries(BufferSemiSlowDown, true); ArraySetAsSeries(BufferSemiSlowUp, true);
  ArraySetAsSeries(BufferSlowDown1, true); ArraySetAsSeries(BufferSlowUp1, true);
  ArraySetAsSeries(BufferSigState, true); ArraySetAsSeries(BufferSendLot, true); ArraySetAsSeries(BufferSendTP, true); ArraySetAsSeries(BufferSendSL, true);
  ArraySetAsSeries(BufferMB_Lot, true); ArraySetAsSeries(BufferMB_TP, true); ArraySetAsSeries(BufferMB_SL, true); ArraySetAsSeries(BufferMS_Lot, true); ArraySetAsSeries(BufferMS_TP, true); ArraySetAsSeries(BufferMS_SL, true);
  ArraySetAsSeries(BufferVoteBuy, true); ArraySetAsSeries(BufferVoteSell, true); ArraySetAsSeries(BufferBaseRange, true); ArraySetAsSeries(BufferTimeFilter, true);

  ArrayResize(G_PrefixSum, rates_total + 1); ArraySetAsSeries(G_PrefixSum, true); G_PrefixSum[rates_total] = 0;
  int calc_limit = (prev_calculated == 0) ? rates_total - 1 : rates_total - prev_calculated + 100;
  if (calc_limit >= rates_total) calc_limit = rates_total - 1;

  if (prev_calculated == 0) {
    double running_sum = 0;
    for (int k = rates_total - 1; k >= 0; k--) { running_sum += close[k]; G_PrefixSum[k] = running_sum; }
  } else {
    double running_sum = (calc_limit + 1 < rates_total) ? G_PrefixSum[calc_limit + 1] : 0;
    for (int k = calc_limit; k >= 0; k--) { running_sum += close[k]; G_PrefixSum[k] = running_sum; }
  }

  int limit = rates_total - prev_calculated;
  if (limit > InpMaxBars) limit = InpMaxBars;
  if (limit > rates_total - 100) limit = rates_total - 100;
  if (limit < 0) return 0;

  if (prev_calculated == 0) { GlobalWins = 0; GlobalLosses = 0; GlobalPending = 0; GlobalNetProfit = 0.0; GlobalSumLossIntensity = 0.0; GlobalSumLossVal = 0.0; GlobalSumLossVotes = 0; GlobalLossCountStats = 0; GlobalSumWinIntensity = 0.0; GlobalSumWinVal = 0.0; GlobalSumWinVotes = 0; GlobalWinCountStats = 0; }

  double k_ema1 = 2.0 / (InpPriceEMAPeriod1 + 1.0);
  double k_ema2 = 2.0 / (InpPriceEMAPeriod2 + 1.0);
  double k_ema3 = 2.0 / (InpPriceEMAPeriod3 + 1.0);

  double cache_v_prev[]; ArrayResize(cache_v_prev, InpVoteEnd + 1); ArrayInitialize(cache_v_prev, 0.0);
  int start_prev_idx = limit + 1;
  if (start_prev_idx + InpLengthKC * InpVoteEnd * 2 < rates_total) {
    for (int k = InpVoteStart; k <= InpVoteEnd; k++) cache_v_prev[k] = GetLinRegVal(start_prev_idx, InpLengthKC * k, high, low, close);
  }

  for (int i = limit; i >= 0; i--) {
    bool ShowVisual = (i <= InpMaxBarsVisual);
    double val = GetLinRegVal(i, InpLengthKC, high, low, close);
    double val5 = GetLinRegVal(i, InpLengthKC * 5, high, low, close) / 4.0;
    double val10 = GetLinRegVal(i, InpLengthKC * 10, high, low, close) / 4.0;
    double val15 = GetLinRegVal(i, InpLengthKC * 15, high, low, close) / 4.0;
    double val20 = GetLinRegVal(i, InpLengthKC * 20, high, low, close) / 4.0;
    BufferVal[i] = val; BufferVal5[i] = val5; BufferVal10[i] = val10; BufferVal15[i] = val15; BufferVal20[i] = val20;

    if (ShowVisual) {
      BufferValColor[i] = GetValColorIndex(val, (i + 1 < rates_total) ? BufferVal[i + 1] : 0);
      BufferVal5Color[i] = GetValColorIndex(val5, (i + 1 < rates_total) ? BufferVal5[i + 1] : 0);
      BufferVal10Color[i] = GetValColorIndex(val10, (i + 1 < rates_total) ? BufferVal10[i + 1] : 0);
      BufferVal15Color[i] = GetValColorIndex(val15, (i + 1 < rates_total) ? BufferVal15[i + 1] : 0);
      BufferVal20Color[i] = GetValColorIndex(val20, (i + 1 < rates_total) ? BufferVal20[i + 1] : 0);
    } else {
      BufferValColor[i] = EMPTY_VALUE; BufferVal5Color[i] = EMPTY_VALUE; BufferVal10Color[i] = EMPTY_VALUE; BufferVal15Color[i] = EMPTY_VALUE; BufferVal20Color[i] = EMPTY_VALUE;
    }

    if (InpShowPriceEMA && ShowVisual) {
      double price = close[i];
      double prevEMA1 = (i + 1 < rates_total) ? BufferEMA1[i + 1] : price; if (prevEMA1 == 0 && i + 1 < rates_total) prevEMA1 = price;
      BufferEMA1[i] = (price * k_ema1) + (prevEMA1 * (1.0 - k_ema1)); DrawMainChartEMA(i, rates_total, time, BufferEMA1, 1, clrBlack, 1);
      double prevEMA2 = (i + 1 < rates_total) ? BufferEMA2[i + 1] : price; if (prevEMA2 == 0 && i + 1 < rates_total) prevEMA2 = price;
      BufferEMA2[i] = (price * k_ema2) + (prevEMA2 * (1.0 - k_ema2)); DrawMainChartEMA(i, rates_total, time, BufferEMA2, 2, clrRed, 1);
      double prevEMA3 = (i + 1 < rates_total) ? BufferEMA3[i + 1] : price; if (prevEMA3 == 0 && i + 1 < rates_total) prevEMA3 = price;
      BufferEMA3[i] = (price * k_ema3) + (prevEMA3 * (1.0 - k_ema3)); DrawMainChartEMA(i, rates_total, time, BufferEMA3, 3, clrBlack, 2);
    } else {
      BufferEMA1[i] = 0.0; BufferEMA2[i] = 0.0; BufferEMA3[i] = 0.0;
    }

    double val_1 = (i + 1 < rates_total) ? BufferVal[i + 1] : 0;
    double delta = val - val_1;
    BufferDelta[i] = delta;
    double delta_1 = (i + 1 < rates_total) ? BufferDelta[i + 1] : 0;
    double delta_2 = (i + 2 < rates_total) ? BufferDelta[i + 2] : 0;

    double safe_stdev_down = 1.0;
    double safe_stdev_up = 1.0;
    if (InpDeltaLen > 0) {
      double delta_stdev = GetStDevCustom(i, InpDeltaLen, BufferDelta);
      double common_stdev = (delta_stdev != 0) ? delta_stdev : 1.0;
      safe_stdev_down = common_stdev; safe_stdev_up = common_stdev;
    } else {
      double dyn_stdev_down = GetDynamicWaveStDev(i, 200, BufferDelta, BufferVal, true);
      safe_stdev_down = (dyn_stdev_down != 0) ? dyn_stdev_down : 1.0;
      double dyn_stdev_up = GetDynamicWaveStDev(i, 200, BufferDelta, BufferVal, false);
      safe_stdev_up = (dyn_stdev_up != 0) ? dyn_stdev_up : 1.0;
    }

    double raw_shift_down = delta - delta_1;
    double intensity_down = raw_shift_down / safe_stdev_down;
    double raw_shift_up = delta_1 - delta;
    double intensity_up = raw_shift_up / safe_stdev_up;

    int buyCount = 0, sellCount = 0;
    if (i + InpLengthKC * InpVoteEnd * 2 < rates_total) {
      for (int k = InpVoteStart; k <= InpVoteEnd; k++) {
        double v_prev = cache_v_prev[k];
        double v = GetLinRegVal(i, InpLengthKC * k, high, low, close);
        cache_v_prev[k] = v;
        if (v > v_prev) buyCount++;
        if (v < v_prev) sellCount++;
      }
    }

    bool buylogic = (buyCount >= InpKCLogic);
    bool selllogic = (sellCount >= InpKCLogic);
    BufferLogBuy[i] = buylogic ? 1.0 : 0.0;
    BufferLogSell[i] = selllogic ? 1.0 : 0.0;
    BufferVoteBuy[i] = (double)buyCount; BufferVoteSell[i] = (double)sellCount;

    double runB_prev = (i + 1 < rates_total) ? BufferRunB[i + 1] : 0;
    double runS_prev = (i + 1 < rates_total) ? BufferRunS[i + 1] : 0;
    double logB_del = (i + InpLenRun < rates_total) ? BufferLogBuy[i + InpLenRun] : 0;
    double logS_del = (i + InpLenRun < rates_total) ? BufferLogSell[i + InpLenRun] : 0;
    BufferRunB[i] = runB_prev + (buylogic ? 1 : 0) - logB_del;
    BufferRunS[i] = runS_prev + (selllogic ? 1 : 0) - logS_del;
    BufferShortRunB[i] = buylogic ? ((i + 1 < rates_total) ? BufferShortRunB[i + 1] : 0) + 1 : 0;
    BufferShortRunS[i] = selllogic ? ((i + 1 < rates_total) ? BufferShortRunS[i + 1] : 0) + 1 : 0;
    bool allisEnoughB = InpUseAtLeast ? (BufferRunB[i] >= InpThreshold) : true;
    bool allisEnoughS = InpUseAtLeast ? (BufferRunS[i] >= InpThreshold) : true;
    bool isEnoughB2 = InpUseShortAtLeast ? (BufferShortRunB[i] >= InpShortThreshold) : false;
    bool isEnoughS2 = InpUseShortAtLeast ? (BufferShortRunS[i] >= InpShortThreshold) : false;

    bool small_0 = IsSmallBody(i, high, low, open, close);
    bool smllupcandle_0 = (close[i] > open[i]) || (close[i] < open[i] && small_0);
    bool smalldncandle_0 = (close[i] < open[i]) || (close[i] > open[i] && small_0);
    bool bigupcandle_0 = (close[i] > open[i]) && !small_0;
    bool bigdncandle_0 = (close[i] < open[i]) && !small_0;
    bool bigupcandle_1 = (close[i + 1] > open[i + 1]) && !IsSmallBody(i+1, high, low, open, close);
    bool bigdncandle_1 = (close[i + 1] < open[i + 1]) && !IsSmallBody(i+1, high, low, open, close);

    double abn_threshold = 999999.0;
    bool is_abn_0 = false;
    if (InpUseAbnormal) {
      if (InpAbnormalLen > 0) abn_threshold = GetAbnormalThresholdFixed(i, rates_total, open, close);
      else abn_threshold = GetAbnormalThresholdDynamic(i, rates_total, open, close, BufferVal, InpAbnormalMult1);
      double current_body = MathAbs(close[i] - open[i]);
      is_abn_0 = (current_body > abn_threshold);
    }
    BufferAbnormal[i] = is_abn_0 ? 1.0 : 0.0;

    bool is_slowing_downcal = (val < val_1) && (intensity_down >= InpMinThreshold) && (intensity_down <= InpMaxThreshold) && (delta_1 > delta_2);
    bool is_slowing_upcal = (val > val_1) && (intensity_up >= InpMinThreshold) && (intensity_up <= InpMaxThreshold) && (delta_1 < delta_2);
    BufferSlowDownBase[i] = is_slowing_downcal ? 1.0 : 0.0;
    BufferSlowUpBase[i] = is_slowing_upcal ? 1.0 : 0.0;
    bool prev_slowing_downcal = (i + 1 < rates_total) ? (BufferSlowDownBase[i + 1] != 0.0) : false;
    bool prev_slowing_upcal = (i + 1 < rates_total) ? (BufferSlowUpBase[i + 1] != 0.0) : false;
    bool is_slowing_downcal2 = (val < val_1) && (intensity_down >= InpMinThreshold) && (intensity_down <= InpMaxThreshold) && prev_slowing_downcal;
    bool is_slowing_upcal2 = (val > val_1) && (intensity_up >= InpMinThreshold) && (intensity_up <= InpMaxThreshold) && prev_slowing_upcal;
    bool is_slowing_down1 = is_slowing_downcal || is_slowing_downcal2;
    bool is_slowing_up1 = is_slowing_upcal || is_slowing_upcal2;
    BufferSlowDown1[i] = is_slowing_down1 ? 1.0 : 0.0;
    BufferSlowUp1[i] = is_slowing_up1 ? 1.0 : 0.0;

    double val_2 = (i + 2 < rates_total) ? BufferVal[i + 2] : 0;
    double val_3 = (i + 3 < rates_total) ? BufferVal[i + 3] : 0;
    double base_range_cal = GetBaseRangeValue(i, rates_total, open, close, BufferVal);
    BufferBaseRange[i] = base_range_cal;

    bool semi_is_slowing_down_calc = val < -0.08888 && (val < val_1) && (delta > delta_1) && bigdncandle_1 && (bigdncandle_0 || smllupcandle_0) && !is_abn_0 && base_range_cal > 0.8888;
    bool semi_is_slowing_up_calc = val > 0.08888 && (val > val_1) && (delta < delta_1) && bigupcandle_1 && (bigupcandle_0 || smalldncandle_0) && !is_abn_0 && base_range_cal > 0.8888;
    bool semi_is_slowing_down = InpValCheck ? (val_1 < val_2 && val_2 < val_3) && semi_is_slowing_down_calc : semi_is_slowing_down_calc;
    bool semi_is_slowing_up = InpValCheck ? (val_1 > val_2 && val_2 > val_3) && semi_is_slowing_up_calc : semi_is_slowing_up_calc;
    BufferSemiSlowDown[i] = semi_is_slowing_down ? 1.0 : 0.0;
    BufferSemiSlowUp[i] = semi_is_slowing_up ? 1.0 : 0.0;

    double prev_semi_down = (i + 1 < rates_total) ? BufferSemiSlowDown[i + 1] : 0.0;
    double prev_semi_up = (i + 1 < rates_total) ? BufferSemiSlowUp[i + 1] : 0.0;
    bool is_slowing_down = is_slowing_down1 && (prev_semi_down != 0.0) && ((smllupcandle_0 || bigdncandle_0) && close[i] > high[i + 1]) && !is_abn_0;
    bool is_slowing_up = is_slowing_up1 && (prev_semi_up != 0.0) && ((smalldncandle_0 || bigupcandle_0) && close[i] < high[i + 1]) && !is_abn_0;

    bool buysignal_final_check = val < val_1 && is_slowing_down && buylogic && base_range_cal > 0.9999;
    bool sellsignal_final_check = val > val_1 && is_slowing_up && selllogic && base_range_cal > 0.9999;
    BufferSigStateBuy[i] = buysignal_final_check ? 1.0 : 0.0;
    BufferSigStateSell[i] = sellsignal_final_check ? 1.0 : 0.0;
    bool buysignalnotpre = buysignal_final_check && ((i + 1 < rates_total ? BufferSigStateBuy[i + 1] : 0) == 0.0);
    bool sellsignalnotpre = sellsignal_final_check && ((i + 1 < rates_total ? BufferSigStateSell[i + 1] : 0) == 0.0);
    bool checkbuysignalcon = InpValCheck ? (val > -0.00001 && val > val_1 && val_1 > val_2) : (val > 0 && val > val_1);
    bool checksellsignalcon = InpValCheck ? (val < 0.00001 && val < val_1 && val_1 < val_2) : (val < 0 && val < val_1);
    bool finalsigB = checksellsignalcon && allisEnoughB && !isEnoughB2;
    bool finalsigS = checkbuysignalcon && allisEnoughS && !isEnoughS2;
    bool finalBBB = buysignalnotpre && allisEnoughB && !isEnoughB2;
    bool finalSSS = sellsignalnotpre && allisEnoughS && !isEnoughS2;

    BufferSigBuyFlag[i] = finalBBB ? 1 : 0; BufferSigSellFlag[i] = finalSSS ? 1 : 0; BufferWaitBuyFlag[i] = finalsigB ? 1 : 0; BufferWaitSellFlag[i] = finalsigS ? 1 : 0;

    bool isTimeAllowed = CheckTimeFilter(time[i]);
    if (IsHolidaySeason(time[i])) isTimeAllowed = false;
    BufferTimeFilter[i] = isTimeAllowed ? 1.0 : 0.0;
    bool newsBlock = false;
    if (i == 0 && InpUseNewsFilter) newsBlock = IsNewsBlocking(time[i]);
    if (newsBlock && i == 0) { finalBBB = false; finalSSS = false; }

    if (ShowVisual) {
      if (finalsigB) { CPEAi_GUI::DrawBackgroundZone(Prefix + "BG_Sub_" + IntegerToString((int)time[i]), time[i], time[i] + PeriodSeconds(), C'225,225,225', -1); CPEAi_GUI::DrawBackgroundZone(Prefix + "BG_Main_" + IntegerToString((int)time[i]), time[i], time[i] + PeriodSeconds(), C'225,225,225', 0); }
      else if (finalsigS) { CPEAi_GUI::DrawBackgroundZone(Prefix + "BG_Sub_" + IntegerToString((int)time[i]), time[i], time[i] + PeriodSeconds(), C'255,215,215', -1); CPEAi_GUI::DrawBackgroundZone(Prefix + "BG_Main_" + IntegerToString((int)time[i]), time[i], time[i] + PeriodSeconds(), C'255,215,215', 0); }
      else { ObjectDelete(0, Prefix + "BG_Sub_" + IntegerToString((int)time[i])); ObjectDelete(0, Prefix + "BG_Main_" + IntegerToString((int)time[i])); }
      ManageArrows(i, rates_total, time, high, low, BufferVal, finalsigB, finalsigS, finalBBB, finalSSS, isTimeAllowed, semi_is_slowing_up, semi_is_slowing_down);
    }

    BufferSigState[i] = 0; BufferSendLot[i] = 0; BufferSendTP[i] = 0; BufferSendSL[i] = 0; BufferMB_Lot[i] = 0; BufferMB_TP[i] = 0; BufferMB_SL[i] = 0; BufferMS_Lot[i] = 0; BufferMS_TP[i] = 0; BufferMS_SL[i] = 0;

    double calcBalance = (InpBalance > 0) ? InpBalance : AccountInfoDouble(ACCOUNT_BALANCE);
    double tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
    double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
    double riskMoney = 0.0;
    if (InpRiskMode == RISK_MODE_MONEY) riskMoney = InpRiskMoney;
    else if (InpRiskMode == RISK_MODE_PERCENT) riskMoney = calcBalance * (InpRisk / 100.0);
    double padding = InpSLPadding * _Point;
    double contractSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
    double accountLev = (double)AccountInfoInteger(ACCOUNT_LEVERAGE);
    double leverage = (InpLeverage > 0) ? (double)InpLeverage : (accountLev > 0 ? accountLev : 100);
    double maxLotLev = (close[i] > 0) ? (calcBalance * leverage) / (close[i] * contractSize) : 999;
    double spreadPoint = (InpSpread > 0) ? (double)InpSpread : (double)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
    double spreadVal = spreadPoint * _Point;

    if (InpDrawSignalLines && isTimeAllowed) {
      if (finalBBB) {
        double swingLow = low[i];
        if (InpSWCount <= 0) swingLow = GetDynamicSwingPrice(i, 200, high, low, BufferVal, true);
        else { for (int k = 1; k < InpSWCount; k++) if (i + k < rates_total && low[i + k] < swingLow) swingLow = low[i + k]; }
        double slPriceBid = swingLow - padding;
        double distPriceB = (close[i] + spreadVal) - slPriceBid;
        double distTicksB = (distPriceB > 0) ? distPriceB / tickSize : 0;
        double calcLotB = 0;
        if (InpRiskMode == RISK_MODE_FIXED_LOT) calcLotB = InpFixedLot;
        else calcLotB = (distTicksB * tickValue > 0) ? riskMoney / (distTicksB * tickValue) : 0;
        double finalLotB = MathMin(MathMax(calcLotB, 0.01), maxLotLev);
        finalLotB = VerifyVolume(finalLotB);
        double rewardB = distPriceB * InpTPRatio;
        double tpPriceBid = (close[i] + spreadVal) + rewardB;
        BufferSigState[i] = 1.0; BufferSendLot[i] = finalLotB; BufferSendTP[i] = tpPriceBid; BufferSendSL[i] = slPriceBid;
        int endBarIdx = 0;
        int outcome = 0;
        if (InpBalance > 0) {
          outcome = GetTradeOutcome(i, true, close[i], slPriceBid, tpPriceBid, high, low, endBarIdx);
          int duration_bars = (endBarIdx > 0) ? (i - endBarIdx) : 0;
          double riskMoneyCalc = (InpRiskMode == RISK_MODE_FIXED_LOT) ? (distTicksB * tickValue * finalLotB) : riskMoney;
          
          // [FIX] Use GetDayName helper function
          datetime thaiTime = time[i] + (InpTimeOffset * 3600);
          MqlDateTime dt; TimeToStruct(time[i], dt);
          string dayName = GetDayName(dt.day_of_week);
          string timeDateStr = TimeToString(time[i], TIME_DATE);
          string timeMinStr = TimeToString(thaiTime, TIME_MINUTES);
          
          bool is_abn_prev = (i + 1 < rates_total) ? (BufferAbnormal[i + 1] != 0.0) : false;
          double abn_threshold_prev = 0.0;
          if (InpUseAbnormal) {
             if (InpAbnormalLen > 0) abn_threshold_prev = GetAbnormalThresholdFixed(i + 1, rates_total, open, close);
             else abn_threshold_prev = GetAbnormalThresholdDynamic(i + 1, rates_total, open, close, BufferVal, InpAbnormalMult1);
          }
          double int_prev = (safe_stdev_down != 0) ? (delta_1 - delta_2) / safe_stdev_down : 0;
          double ema_dist = (BufferEMA2[i] != 0 && BufferEMA2[i] != EMPTY_VALUE) ? (close[i] - BufferEMA2[i]) / _Point : 0;
          string ema_trend = "Mix";
          if (BufferEMA1[i] != 0 && BufferEMA2[i] != 0 && BufferEMA3[i] != 0) {
             if (BufferEMA1[i] > BufferEMA2[i] && BufferEMA2[i] > BufferEMA3[i]) ema_trend = "Bull";
             else if (BufferEMA1[i] < BufferEMA2[i] && BufferEMA2[i] < BufferEMA3[i]) ema_trend = "Bear";
          } else ema_trend = "Off";
          double range = high[i] - low[i];
          double body = MathAbs(close[i] - open[i]);
          double body_pct = (range > 0) ? (body / range) * 100.0 : 0.0;
          double sl_points = (distPriceB / _Point);

          // Pre-calc to simplify FileWrite and avoid syntax errors
          double br_next = GetBaseRangeValue(i + 1, rates_total, open, close, BufferVal); 

          if (outcome == 1) { 
             GlobalWins++; GlobalNetProfit += CalculateProfitUSD(1, riskMoneyCalc); GlobalSumWinIntensity += MathAbs(intensity_down); GlobalSumWinVal += MathAbs(val); GlobalSumWinVotes += buyCount; GlobalWinCountStats++; 
             Print("WIN  | BUY  | ", dayName, " ", timeDateStr, " | ", timeMinStr, " | Int: ", DoubleToString(MathAbs(intensity_down), 2), " | Vote: ", IntegerToString(buyCount)); 
          }
          else if (outcome == -1) { 
             GlobalLosses++; GlobalNetProfit += CalculateProfitUSD(-1, riskMoneyCalc); GlobalSumLossIntensity += MathAbs(intensity_down); GlobalSumLossVal += MathAbs(val); GlobalSumLossVotes += buyCount; GlobalLossCountStats++; 
             Print("LOSS | BUY  | ", dayName, " ", timeDateStr, " | ", timeMinStr, " | Int: ", DoubleToString(MathAbs(intensity_down), 2), " | Vote: ", IntegerToString(buyCount));
          }
          else GlobalPending++;
          
          if (file_handle != INVALID_HANDLE) {
             string result = (outcome == 1 ? "WIN" : (outcome == -1 ? "LOSS" : "PENDING"));
             string abnStr = is_abn_0 ? "TRUE" : "FALSE";
             string abnPrevStr = is_abn_prev ? "TRUE" : "FALSE";
             
             FileWrite(file_handle, result, "BUY", dayName,
                timeDateStr, timeMinStr,
                DoubleToString(MathAbs(intensity_down), 2), DoubleToString(MathAbs(int_prev), 2), DoubleToString(val, 5),
                DoubleToString(val_1, 5), DoubleToString(val_2, 5), DoubleToString(val_3, 5), DoubleToString(delta, 5),
                DoubleToString(delta_1, 5), IntegerToString(buyCount), DoubleToString(BufferShortRunB[i], 0),
                DoubleToString(base_range_cal, 5), DoubleToString(br_next, 5),
                DoubleToString(abn_threshold, 2), DoubleToString(abn_threshold_prev, 2), abnStr, abnPrevStr,
                DoubleToString(sl_points, 0), IntegerToString(duration_bars),
                DoubleToString(ema_dist, 0), ema_trend, DoubleToString(body_pct, 1), IntegerToString(spread[i]));
          }
        }
        if (ShowVisual) {
          int visualDur = (InpBalance > 0 && endBarIdx > 0) ? (i - endBarIdx) : InpBarPlot;
          DrawSignalSetup(time[i], close[i] + spreadVal, slPriceBid, tpPriceBid, true, outcome, visualDur);
        }
      }

      if (finalSSS) {
        double swingHigh = high[i];
        if (InpSWCount <= 0) swingHigh = GetDynamicSwingPrice(i, 200, high, low, BufferVal, false);
        else { for (int k = 1; k < InpSWCount; k++) if (i + k < rates_total && high[i + k] > swingHigh) swingHigh = high[i + k]; }
        double slLevelBid = swingHigh + padding;
        double slLevelAsk = slLevelBid + spreadVal;
        double distPriceS = slLevelAsk - close[i];
        double distTicksS = (distPriceS > 0) ? distPriceS / tickSize : 0;
        double calcLotS = 0;
        if (InpRiskMode == RISK_MODE_FIXED_LOT) calcLotS = InpFixedLot;
        else calcLotS = (distTicksS * tickValue > 0) ? riskMoney / (distTicksS * tickValue) : 0;
        double finalLotS = MathMin(MathMax(calcLotS, 0.01), maxLotLev);
        finalLotS = VerifyVolume(finalLotS);
        double rewardS = distPriceS * InpTPRatio;
        double tpPriceAsk = close[i] - rewardS;
        BufferSigState[i] = 2.0; BufferSendLot[i] = finalLotS; BufferSendTP[i] = tpPriceAsk; BufferSendSL[i] = slLevelAsk;
        int endBarIdx = 0;
        int outcome = 0;
        if (InpBalance > 0) {
           outcome = GetTradeOutcome(i, false, close[i], slLevelBid, tpPriceAsk - spreadVal, high, low, endBarIdx);
           double riskMoneyCalc = (InpRiskMode == RISK_MODE_FIXED_LOT) ? (distTicksS * tickValue * finalLotS) : riskMoney;
           
           // [FIX] Use GetDayName helper function
           datetime thaiTime = time[i] + (InpTimeOffset * 3600);
           MqlDateTime dt; TimeToStruct(time[i], dt);
           string dayName = GetDayName(dt.day_of_week);
           string timeDateStr = TimeToString(time[i], TIME_DATE);
           string timeMinStr = TimeToString(thaiTime, TIME_MINUTES);
           
           bool is_abn_prev = (i + 1 < rates_total) ? (BufferAbnormal[i + 1] != 0.0) : false;
           double abn_threshold_prev = 0.0;
           if (InpUseAbnormal) {
              if (InpAbnormalLen > 0) abn_threshold_prev = GetAbnormalThresholdFixed(i + 1, rates_total, open, close);
              else abn_threshold_prev = GetAbnormalThresholdDynamic(i + 1, rates_total, open, close, BufferVal, InpAbnormalMult1);
           }
           double int_prev = (safe_stdev_up != 0) ? (delta_1 - delta_2) / safe_stdev_up : 0;
           double ema_dist = (BufferEMA2[i] != 0 && BufferEMA2[i] != EMPTY_VALUE) ? (close[i] - BufferEMA2[i]) / _Point : 0;
           string ema_trend = "Mix";
           if (BufferEMA1[i] != 0 && BufferEMA2[i] != 0 && BufferEMA3[i] != 0) {
              if (BufferEMA1[i] > BufferEMA2[i] && BufferEMA2[i] > BufferEMA3[i]) ema_trend = "Bull";
              else if (BufferEMA1[i] < BufferEMA2[i] && BufferEMA2[i] < BufferEMA3[i]) ema_trend = "Bear";
           } else ema_trend = "Off";
           double range = high[i] - low[i];
           double body = MathAbs(close[i] - open[i]);
           double body_pct = (range > 0) ? (body / range) * 100.0 : 0.0;
           double sl_points = (distPriceS / _Point);

           double br_next = GetBaseRangeValue(i + 1, rates_total, open, close, BufferVal);

           if (outcome == 1) { 
              GlobalWins++; GlobalNetProfit += CalculateProfitUSD(1, riskMoneyCalc); GlobalSumWinIntensity += MathAbs(intensity_up); GlobalSumWinVal += MathAbs(val); GlobalSumWinVotes += sellCount; GlobalWinCountStats++; 
              Print("WIN  | SELL | ", dayName, " ", timeDateStr, " | ", timeMinStr, " | Int: ", DoubleToString(MathAbs(intensity_up), 2), " | Vote: ", IntegerToString(sellCount)); 
           }
           else if (outcome == -1) { 
              GlobalLosses++; GlobalNetProfit += CalculateProfitUSD(-1, riskMoneyCalc); GlobalSumLossIntensity += MathAbs(intensity_up); GlobalSumLossVal += MathAbs(val); GlobalSumLossVotes += sellCount; GlobalLossCountStats++; 
              Print("LOSS | SELL | ", dayName, " ", timeDateStr, " | ", timeMinStr, " | Int: ", DoubleToString(MathAbs(intensity_up), 2), " | Vote: ", IntegerToString(sellCount));
           }
           else GlobalPending++;

           if (file_handle != INVALID_HANDLE) {
              string result = (outcome == 1 ? "WIN" : (outcome == -1 ? "LOSS" : "PENDING"));
              string abnStr = is_abn_0 ? "TRUE" : "FALSE";
              string abnPrevStr = is_abn_prev ? "TRUE" : "FALSE";
              
              FileWrite(file_handle, result, "SELL", dayName,
                 timeDateStr, timeMinStr,
                 DoubleToString(MathAbs(intensity_up), 2), DoubleToString(MathAbs(int_prev), 2), DoubleToString(val, 5),
                 DoubleToString(val_1, 5), DoubleToString(val_2, 5), DoubleToString(val_3, 5), DoubleToString(delta, 5),
                 DoubleToString(delta_1, 5), IntegerToString(sellCount), DoubleToString(BufferShortRunS[i], 0),
                 DoubleToString(base_range_cal, 5), DoubleToString(br_next, 5),
                 DoubleToString(abn_threshold, 2), DoubleToString(abn_threshold_prev, 2), abnStr, abnPrevStr,
                 DoubleToString(sl_points, 0), IntegerToString(duration_bars),
                 DoubleToString(ema_dist, 0), ema_trend, DoubleToString(body_pct, 1), IntegerToString(spread[i]));
           }
        }
        if (ShowVisual) {
           int visualDur = (InpBalance > 0 && endBarIdx > 0) ? (i - endBarIdx) : InpBarPlot;
           DrawSignalSetup(time[i], close[i] + spreadVal, slLevelAsk, tpPriceAsk, false, outcome, visualDur);
        }
      }
      
      if (!finalBBB && !finalSSS) {
         string tStr = IntegerToString((int)time[i]);
         ObjectDelete(0, TradePrefix + tStr + "_En");
         ObjectDelete(0, TradePrefix + tStr + "_SL");
         ObjectDelete(0, TradePrefix + tStr + "_TP");
      }
    }

    if (i == 0) {
      double avgLossVal = (GlobalLossCountStats > 0) ? GlobalSumLossVal / GlobalLossCountStats : 0.0;
      double avgWinVal = (GlobalWinCountStats > 0) ? GlobalSumWinVal / GlobalWinCountStats : 0.0;
      G_BuyCount = buyCount; G_SellCount = sellCount; G_IsAbnormal = is_abn_0; G_IsTimeAllowed = isTimeAllowed; G_Intensity = intensity_down; G_Delta = delta; G_Delta1 = delta_1; G_BaseRange = base_range_cal; G_FinalBBB = finalBBB; G_FinalSSS = finalSSS; G_FinalSigB = finalsigB; G_FinalSigS = finalsigS; G_SemiDown = semi_is_slowing_down; G_SemiUp = semi_is_slowing_up; G_NewsBlock = newsBlock; G_AvgLoss = avgLossVal; G_AvgWin = avgWinVal;
      G_RunB = (int)BufferShortRunB[i]; G_RunS = (int)BufferShortRunS[i]; // [ADDED]
      UpdateRealtimeTPSL(high, low, close, time);
    }
  }
  ChartRedraw(0);
  return (rates_total);
}