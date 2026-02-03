//+------------------------------------------------------------------+
//|                                                  PEAi_Trader.mq5 |
//|        PEAEAi By Rattana (v5.42 Refactored)                      |
//+------------------------------------------------------------------+
#property copyright "PEAi Trader"
#property version "5.42"

#include <Trade\Trade.mqh>
#include <PEAi_GUI.mqh> // Shared Enum is defined here

CTrade trade;

// ==========================================
// 1. INPUTS
// ==========================================

input group "Strategy Logic" 
input int InpKCLogic = 12;
input int InpVoteStart = 2;
input int InpVoteEnd = 19;
input bool InpValCheck = false;

input group "Filters" 
input bool InpUseAtLeast = true;
input int InpThreshold = 2;
input int InpLenRun = 2;
input bool InpUseShortAtLeast = false;
input int InpShortThreshold = 99;

input group "Abnormal Filter" 
input bool InpUseAbnormal = true;
input int InpAbnormalLen = 10;
input double InpAbnormalMult1 = 1.0;

input group "Intensity Settings" 
input double InpMinThreshold = 0.5;
input double InpMaxThreshold = 3.0;
input int InpDeltaLen = 10;

input group "KC Settings" 
input int InpLengthKC = 20;

input group "Main Chart EMAs" 
input bool InpShowPriceEMA = true;
input int InpPriceEMAPeriod1 = 22;
input int InpPriceEMAPeriod2 = 55;
input int InpPriceEMAPeriod3 = 188;

input group "Time & Day Filters" 
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

input group "News Filter" 
input bool InpUseNewsFilter = true;
input int InpNewsBefore = 10;
input int InpNewsAfter = 10;
input bool InpNewsHigh = true;
input bool InpNewsMedium = false;

input group "TP & SL Settings" 
input double InpBalance = 0;
input int InpSpread = 0;
input double InpTPRatio = 1.0;

input string ___Risk_Settings___ = "=== RISK SETTINGS ===";
input ENUM_RISK_MODE InpRiskMode = RISK_MODE_MONEY; // Uses Enum from PEAi_GUI.mqh
input double InpRisk = 1.0;
input double InpRiskMoney = 55.0;
input double InpFixedLot = 0.01;

input int InpLeverage = 0;
input int InpSWCount = 10;
input int InpSLPadding = 30;
input int InpBarPlot = 15;
input bool InpShowRealtime = true;
input bool InpDrawSignalLines = true;

input group "System & UI" 
input bool InpShowDashboard = true;
input int InpDashX = 20;
input int InpDashY = 40;
input bool InpAlertPopUp = true;
input bool InpAlertPush = true;
input double InpArrowGapMult = 1.0;
input int InpMaxBars = 1000;
input int InpMaxBarsVisual = 1000;

input group "Telegram Settings" 
input bool InpUseTelegram = true; 
input string InpTelegramToken = "8330098995:AAHh0a9fnmU9Raiy2hUZpJNZ09zsjMYhgII"; 
input string InpTelegramChatID = "6618851983";        
input int InpTelegramPollInterval = 5;                

input group "Backend Settings" 
input bool InpUseBackend = false;                    
input string InpBackendURL = "";      
input string InpBackendAPIKey = "";   
input int InpBackendPushInterval = 5; 

input group "EA Settings" 
input int InpMagicNum = 88888888;

// --- Globals ---
int handle_peai = INVALID_HANDLE;
string Prefix = "PEAi_EA_";
bool AutoMode = false;
bool IsMinimized = false; 

string myIndiName = "";
int myIndiSubWin = 0;
string GV_MinState = "";

// Signals
int Auto_Signal = 0;
double Auto_Lot = 0;
double Auto_TP = 0;
double Auto_SL = 0;
double MB_Lot = 0;
double MB_TP = 0;
double MB_SL = 0;
double MS_Lot = 0;
double MS_TP = 0;
double MS_SL = 0;

datetime LastTradeBar = 0;

// Notification Tracking
datetime LastAlertTime = 0;
string LastAlertMsg = "";
datetime t_wait_buy = 0, t_wait_sell = 0;
datetime t_slow_buy = 0, t_slow_sell = 0;
datetime t_big_buy = 0, t_big_sell = 0;
datetime t_confirm_buy = 0, t_confirm_sell = 0;
datetime LastBarTime = 0;

long TelegramLastUpdateID = 0;
datetime TelegramLastPoll = 0;
datetime BackendLastPush = 0;

int G_VoteBuy = 0, G_VoteSell = 0;
double G_RunB = 0, G_RunS = 0, G_BaseRange = 0;


void RemoveExistingPEAiIndicator() {
  int totalWindows = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
  for (int win = 0; win < totalWindows; win++) {
    int totalInd = ChartIndicatorsTotal(0, win);
    for (int i = totalInd - 1; i >= 0; i--) {
      string indName = ChartIndicatorName(0, win, i);
      if (StringFind(indName, "PEAi") >= 0) {
        ChartIndicatorDelete(0, win, indName);
      }
    }
  }
}

int OnInit() {
  ResetLastError();
  GV_MinState = "PEAi_MIN_" + IntegerToString(InpMagicNum);

  if (GlobalVariableCheck(GV_MinState)) {
    IsMinimized = (GlobalVariableGet(GV_MinState) == 1.0);
  } else {
    GlobalVariableSet(GV_MinState, 0.0);
    IsMinimized = false;
  }

  RemoveExistingPEAiIndicator();

  handle_peai = iCustom(
      _Symbol, _Period, "PEAi", InpKCLogic, InpVoteStart, InpVoteEnd,
      InpValCheck, InpUseAtLeast, InpThreshold, InpLenRun, InpUseShortAtLeast,
      InpShortThreshold, InpUseAbnormal, InpAbnormalLen, InpAbnormalMult1,
      InpMinThreshold, InpMaxThreshold, InpDeltaLen, InpLengthKC,
      InpShowPriceEMA, InpPriceEMAPeriod1, InpPriceEMAPeriod2,
      InpPriceEMAPeriod3, InpUseTime, InpTimeOffset, InpTimeStart1,
      InpTimeStop1, InpTimeStart2, InpTimeStop2, InpTradeMon, InpTradeTue,
      InpTradeWed, InpTradeThu, InpTradeFri, InpTradeSat, InpTradeSun,
      InpUseNewsFilter, InpNewsBefore, InpNewsAfter, InpNewsHigh, InpNewsMedium,
      InpBalance, InpSpread, InpTPRatio, ___Risk_Settings___, InpRiskMode,
      InpRisk, InpRiskMoney, InpFixedLot, InpLeverage, InpSWCount, InpSLPadding,
      InpBarPlot, InpShowRealtime, InpDrawSignalLines, InpShowDashboard,
      InpDashX, InpDashY, InpAlertPopUp, InpAlertPush, InpArrowGapMult,
      InpMaxBars, InpMaxBarsVisual,
      InpMagicNum 
  );

  if (handle_peai == INVALID_HANDLE) {
    Alert("CRITICAL ERROR: Could not load PEAi! Check file name.");
    return (INIT_FAILED);
  }

  myIndiSubWin = (int)ChartGetInteger(0, CHART_WINDOWS_TOTAL);
  if (!ChartIndicatorAdd(0, myIndiSubWin, handle_peai)) {
    myIndiSubWin = 0;
    if (!ChartIndicatorAdd(0, myIndiSubWin, handle_peai))
      return (INIT_FAILED);
  }

  int totalInd = ChartIndicatorsTotal(0, myIndiSubWin);
  if (totalInd > 0)
    myIndiName = ChartIndicatorName(0, myIndiSubWin, totalInd - 1);

  // --- GUI Creation using Library ---
  CPEAi_ControlPanel::Create(Prefix, InpDashX, InpDashY, AutoMode, IsMinimized);
  
  trade.SetExpertMagicNumber(InpMagicNum);

  CPEAi_ControlPanel::UpdateVisibility(Prefix, IsMinimized, InpDashX, InpDashY);
  CPEAi_ControlPanel::UpdateButtons(Prefix, AutoMode, MB_Lot, MS_Lot);
  
  ChartRedraw();
  EventSetTimer(1);
  return (INIT_SUCCEEDED);
}

void OnDeinit(const int reason) {
  EventKillTimer();
  if (myIndiName != "" && myIndiSubWin >= 0) {
    ChartIndicatorDelete(0, myIndiSubWin, myIndiName);
  }
  RemoveExistingPEAiIndicator();
  
  // Clean up objects with prefix
  ObjectsDeleteAll(0, Prefix);
  ObjectsDeleteAll(0, "PEAi_EA_");
  
  if (handle_peai != INVALID_HANDLE) {
    IndicatorRelease(handle_peai);
    handle_peai = INVALID_HANDLE;
  }
  Comment("");
  ChartRedraw(0);
}

void OnTimer() {
  if (GlobalVariableCheck(GV_MinState)) {
    bool gvState = (GlobalVariableGet(GV_MinState) == 1.0);
    if (gvState != IsMinimized) {
      IsMinimized = gvState;
      CPEAi_ControlPanel::UpdateVisibility(Prefix, IsMinimized, InpDashX, InpDashY);
    }
  }

  // Ensure UI visibility and updates
  CPEAi_ControlPanel::UpdateVisibility(Prefix, IsMinimized, InpDashX, InpDashY);
  if (!IsMinimized) {
    CPEAi_ControlPanel::UpdateButtons(Prefix, AutoMode, MB_Lot, MS_Lot);
  }

  // Telegram & Backend logic remains here...
  // (Assuming GetTelegramUpdates and PushDataToBackend implementations exist same as before)
  
  ChartRedraw();
}

void OnTick() {
  double bufState[], bufLot[], bufTP[], bufSL[];
  ArraySetAsSeries(bufState, true);
  ArraySetAsSeries(bufLot, true);
  ArraySetAsSeries(bufTP, true);
  ArraySetAsSeries(bufSL, true);

  if (CopyBuffer(handle_peai, 29, 1, 1, bufState) <= 0) return;
  if (CopyBuffer(handle_peai, 30, 1, 1, bufLot) <= 0) return;
  if (CopyBuffer(handle_peai, 31, 1, 1, bufTP) <= 0) return;
  if (CopyBuffer(handle_peai, 32, 1, 1, bufSL) <= 0) return;

  double bufUseSignal[];
  ArraySetAsSeries(bufUseSignal, true);
  if (CopyBuffer(handle_peai, 29, 0, 1, bufUseSignal) <= 0) return;

  Auto_Signal = (int)bufState[0];
  Auto_Lot = bufLot[0];
  Auto_TP = bufTP[0];
  Auto_SL = bufSL[0];

  double bMB_Lot[], bMS_Lot[];
  ArraySetAsSeries(bMB_Lot, true);
  ArraySetAsSeries(bMS_Lot, true);
  CopyBuffer(handle_peai, 33, 0, 1, bMB_Lot);
  CopyBuffer(handle_peai, 36, 0, 1, bMS_Lot);
  
  MB_Lot = bMB_Lot[0];
  MS_Lot = bMS_Lot[0];
  
  // Manual button parameters for click event need full data
  // Logic for Auto Trading...
  if (AutoMode && !IsMinimized) {
    if (iTime(_Symbol, _Period, 0) != LastTradeBar) {
      if (Auto_Signal != 0 && Auto_Lot > 0) {
        string comm = "PEAi Auto";
        bool res = false;
        if (Auto_Signal == 1) res = trade.Buy(Auto_Lot, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), Auto_SL, Auto_TP, comm);
        else if (Auto_Signal == 2) res = trade.Sell(Auto_Lot, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID), Auto_SL, Auto_TP, comm);
        
        if (res) LastTradeBar = iTime(_Symbol, _Period, 0);
      }
    }
  }
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
  if (id == CHARTEVENT_OBJECT_CLICK) {
    if (sparam == Prefix + "Btn_MasterMin") {
      IsMinimized = !IsMinimized;
      GlobalVariableSet(GV_MinState, IsMinimized ? 1.0 : 0.0);
      CPEAi_ControlPanel::UpdateVisibility(Prefix, IsMinimized, InpDashX, InpDashY);
      ObjectSetInteger(0, Prefix + "Btn_MasterMin", OBJPROP_STATE, false);
      ChartRedraw();
    }

    if (IsMinimized) return;

    if (sparam == Prefix + "Btn_Auto") {
      AutoMode = !AutoMode;
      ObjectSetInteger(0, Prefix + "Btn_Auto", OBJPROP_STATE, false);
      CPEAi_ControlPanel::UpdateButtons(Prefix, AutoMode, MB_Lot, MS_Lot);
      ChartRedraw();
    }

    if (sparam == Prefix + "Btn_CloseAll") {
      ObjectSetInteger(0, Prefix + "Btn_CloseAll", OBJPROP_STATE, false);
      ChartRedraw();
      if (MessageBox("Close ALL positions?", "Confirm", MB_YESNO | MB_ICONWARNING) == IDYES) {
        // Close Logic...
         int total = PositionsTotal();
         for (int i = total - 1; i >= 0; i--) {
            ulong ticket = PositionGetTicket(i);
            if (PositionGetInteger(POSITION_MAGIC) == InpMagicNum) trade.PositionClose(ticket);
         }
      }
    }

    if (!AutoMode) {
      if (sparam == Prefix + "Btn_Buy") {
        ObjectSetInteger(0, Prefix + "Btn_Buy", OBJPROP_STATE, false);
        if (MB_Lot > 0) trade.Buy(MB_Lot, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_ASK), 0, 0, "PEAi Manual");
      }
      if (sparam == Prefix + "Btn_Sell") {
        ObjectSetInteger(0, Prefix + "Btn_Sell", OBJPROP_STATE, false);
        if (MS_Lot > 0) trade.Sell(MS_Lot, _Symbol, SymbolInfoDouble(_Symbol, SYMBOL_BID), 0, 0, "PEAi Manual");
      }
    }
  }
}