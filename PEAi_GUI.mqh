//+------------------------------------------------------------------+
//|                                                     PEAi_GUI.mqh |
//|                                          UI & Drawing Library    |
//+------------------------------------------------------------------+
#property copyright "PEAi 🤖"
#property strict

// ==========================================
// 1. SHARED ENUMS (Defined ONLY here)
// ==========================================
enum ENUM_RISK_MODE {
   RISK_MODE_PERCENT,  // Risk % of Balance
   RISK_MODE_MONEY,    // Fixed Money Risk ($)
   RISK_MODE_FIXED_LOT // Fixed Lot Size
};

// ==========================================
// 2. COLOR PALETTE (Flat Design)
// ==========================================
color C_BG_Main     = C'33,37,43';      // Dark Grey (Atom Theme)
color C_BG_Header   = C'40,44,52';      // Lighter Grey
color C_BG_Panel    = C'33,37,43';      // Panel BG
color C_Text_Main   = C'220,223,228';   // Off-White
color C_Text_Mute   = C'157,165,180';   // Muted Grey
color C_Accent      = C'97,175,239';    // Blue
color C_Success     = C'152,195,121';   // Green
color C_Danger      = C'224,108,117';   // Red
color C_Warning     = C'229,192,123';   // Gold/Orange
color C_Disabled    = C'50,55,62';      // Disabled Grey
color C_Btn_Hover   = C'60,64,72';      // Hover
color C_TaskBar     = C'25,28,32';      // Taskbar Dark

// ==========================================
// 3. PRIMITIVE DRAWING FUNCTIONS
// ==========================================
class CPEAi_GUI {
public:
   // --- Create Flat Button (For EA) ---
   static void CreateFlatButton(string name, int x, int y, int w, int h, string text, color bg, color txt, int zorder=100) {
      if(ObjectFind(0, name) < 0) {
         ObjectCreate(0, name, OBJ_BUTTON, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_FLAT);
         ObjectSetString(0, name, OBJPROP_FONT, "Segoe UI");
         ObjectSetInteger(0, name, OBJPROP_FONTSIZE, 9);
         ObjectSetInteger(0, name, OBJPROP_ZORDER, zorder);
         ObjectSetInteger(0, name, OBJPROP_BACK, false); 
      }
      if(ObjectGetInteger(0, name, OBJPROP_XSIZE) != w) ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
      if(ObjectGetInteger(0, name, OBJPROP_YSIZE) != h) ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
      if(ObjectGetInteger(0, name, OBJPROP_XDISTANCE) != x) ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      if(ObjectGetInteger(0, name, OBJPROP_YDISTANCE) != y) ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      if(ObjectGetString(0, name, OBJPROP_TEXT) != text) ObjectSetString(0, name, OBJPROP_TEXT, text);
      if(ObjectGetInteger(0, name, OBJPROP_BGCOLOR) != bg) ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
      if(ObjectGetInteger(0, name, OBJPROP_COLOR) != txt) ObjectSetInteger(0, name, OBJPROP_COLOR, txt);
      ObjectSetInteger(0, name, OBJPROP_STATE, false);
   }

   // --- Create Panel Background ---
   static void CreatePanelBG(string name, int x, int y, int w, int h, color bg) {
      if(ObjectFind(0, name) < 0) {
         ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, BORDER_RAISED);
         ObjectSetInteger(0, name, OBJPROP_BACK, false);
      }
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
   }

   // --- Create Rectangle Label ---
   static void CreateRect(string name, int x, int y, int w, int h, color bg, int border_type = BORDER_FLAT) {
      if (ObjectFind(0, name) < 0) {
         ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetInteger(0, name, OBJPROP_BACK, false);
      }
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_XSIZE, w);
      ObjectSetInteger(0, name, OBJPROP_YSIZE, h);
      ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bg);
      ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, border_type);
   }

   // --- Create Text Label ---
   static void CreateLabel(string name, int x, int y, string text, int fontsize, color col, bool bold = false, int anchor = ANCHOR_LEFT_UPPER) {
      if (ObjectFind(0, name) < 0) {
         ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0);
         ObjectSetInteger(0, name, OBJPROP_CORNER, CORNER_LEFT_UPPER);
         ObjectSetString(0, name, OBJPROP_FONT, "Segoe UI");
      }
      ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
      ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontsize);
      ObjectSetString(0, name, OBJPROP_TEXT, text);
      ObjectSetInteger(0, name, OBJPROP_COLOR, col);
      ObjectSetInteger(0, name, OBJPROP_ANCHOR, anchor);
   }

   // --- Draw Arrow ---
   static void DrawArrow(string name, datetime time, double price, int arrowCode, color col, int width, int window) {
      if (ObjectFind(0, name) < 0) {
         ObjectCreate(0, name, OBJ_ARROW, window, time, price);
         ObjectSetInteger(0, name, OBJPROP_ARROWCODE, arrowCode);
         ObjectSetInteger(0, name, OBJPROP_COLOR, col);
         ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
         ObjectSetInteger(0, name, OBJPROP_ANCHOR, (arrowCode == 241 || arrowCode == 251 || arrowCode == 233) ? ANCHOR_TOP : ANCHOR_BOTTOM);
      } else {
         ObjectSetInteger(0, name, OBJPROP_TIME, time);
         ObjectSetDouble(0, name, OBJPROP_PRICE, price);
      }
   }
   
   // --- Draw Trend Line ---
   static void DrawTrendLine(string name, datetime t1, double p1, datetime t2, double p2, color col, int width, bool ray=false) {
      if (ObjectFind(0, name) < 0) 
         ObjectCreate(0, name, OBJ_TREND, 0, 0, 0, 0, 0);
      
      ObjectSetInteger(0, name, OBJPROP_TIME, 0, t1);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 0, p1);
      ObjectSetInteger(0, name, OBJPROP_TIME, 1, t2);
      ObjectSetDouble(0, name, OBJPROP_PRICE, 1, p2);
      ObjectSetInteger(0, name, OBJPROP_COLOR, col);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
      ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, ray);
   }
};

// ==========================================
// 4. DASHBOARD LOGIC
// ==========================================
class CPEAi_Dashboard {
public:
   static void DrawVoteProgressBar(string prefix, int x, int y, int w, int h, int buyVotes, int sellVotes) {
      int totalVotes = buyVotes + sellVotes;
      ObjectDelete(0, prefix + "VoteBar_B");
      ObjectDelete(0, prefix + "VoteBar_S");
      ObjectDelete(0, prefix + "VoteBar_Empty");
      ObjectDelete(0, prefix + "Txt_VoteB");
      ObjectDelete(0, prefix + "Txt_VoteS");

      int numWidth = 20;
      int barX = x + numWidth + 5;
      int barW = w - (numWidth * 2) - 10;
      int textY = y - 1;

      if (totalVotes == 0) {
         CPEAi_GUI::CreateRect(prefix + "VoteBar_Empty", barX, y, barW, h, C_BG_Header, BORDER_FLAT);
         return;
      }
      double buyPercent = (double)buyVotes / (double)totalVotes;
      int buyW = (int)(barW * buyPercent);

      if (buyVotes > 0) CPEAi_GUI::CreateRect(prefix + "VoteBar_B", barX, y, buyW, h, C_Success, BORDER_FLAT);
      if (sellVotes > 0) CPEAi_GUI::CreateRect(prefix + "VoteBar_S", barX + buyW, y, barW - buyW, h, C_Danger, BORDER_FLAT);
      if (buyVotes > 0) CPEAi_GUI::CreateLabel(prefix + "Txt_VoteB", x, textY, IntegerToString(buyVotes), 8, C_Success, true, ANCHOR_LEFT_UPPER);
      if (sellVotes > 0) CPEAi_GUI::CreateLabel(prefix + "Txt_VoteS", x + w, textY, IntegerToString(sellVotes), 8, C_Danger, true, ANCHOR_RIGHT_UPPER);
   }
   
   static void Update(string lblPrefix, bool minimized, bool showDash, int x, int y, 
                      int buyCount, int sellCount, bool is_abnormal, bool isTimeAllowed, 
                      double intensity_down, double delta, double delta_1, 
                      bool finalBBB, bool finalSSS, bool finalsigB, bool finalsigS, 
                      bool semi_is_slowing_down, bool semi_is_slowing_up, bool newsBlock, 
                      double baseRange, string symbol, ENUM_TIMEFRAMES period, 
                      double balance, double netProfit, int wins, int losses,
                      string riskModeStr, int runB, int runS) // [MODIFIED] Added runB, runS
   {
      if (!showDash) return;
      int w = 240;
      int h = minimized ? 35 : 330;

      CPEAi_GUI::CreateRect(lblPrefix + "BG", x, y, w, h, C_BG_Main, BORDER_RAISED);
      CPEAi_GUI::CreateRect(lblPrefix + "Header", x, y, w, 35, C_BG_Header);
      CPEAi_GUI::CreateLabel(lblPrefix + "Title", x + 10, y + 8, "QuanTRade ⚡ v5.42", 10, C_Warning, true);

      datetime barStart = iTime(symbol, period, 0);
      long secondsLeft = (barStart + PeriodSeconds(period)) - TimeCurrent();
      if (secondsLeft < 0) secondsLeft = 0;
      string timerStr = StringFormat("%02d:%02d", (int)(secondsLeft / 60), (int)(secondsLeft % 60));
      CPEAi_GUI::CreateLabel(lblPrefix + "Timer", x + w - 35, y + 8, timerStr, 10, (secondsLeft < 30) ? C_Danger : C_Text_Mute, true, ANCHOR_RIGHT_UPPER);

      if (minimized) {
         ObjectDelete(0, lblPrefix + "SigBox"); ObjectDelete(0, lblPrefix + "SigMain"); ObjectDelete(0, lblPrefix + "SigSub");
         ObjectDelete(0, lblPrefix + "Div_1"); ObjectDelete(0, lblPrefix + "Div_2");
         ObjectDelete(0, lblPrefix + "L_Vote"); ObjectDelete(0, lblPrefix + "V_Vote");
         ObjectDelete(0, lblPrefix + "L_Trend"); ObjectDelete(0, lblPrefix + "V_Trend");
         ObjectDelete(0, lblPrefix + "L_Int"); ObjectDelete(0, lblPrefix + "V_Int");
         ObjectDelete(0, lblPrefix + "L_Base"); ObjectDelete(0, lblPrefix + "V_Base");
         ObjectDelete(0, lblPrefix + "L_Cdl"); ObjectDelete(0, lblPrefix + "V_Cdl");
         ObjectDelete(0, lblPrefix + "L_Mkt"); ObjectDelete(0, lblPrefix + "V_Mkt");
         ObjectDelete(0, lblPrefix + "L_Run"); ObjectDelete(0, lblPrefix + "V_Run");
         ObjectDelete(0, lblPrefix + "S1"); ObjectDelete(0, lblPrefix + "S1V");
         ObjectDelete(0, lblPrefix + "S2"); ObjectDelete(0, lblPrefix + "S2V");
         ObjectDelete(0, lblPrefix + "VoteBar_B"); ObjectDelete(0, lblPrefix + "VoteBar_S");
         ObjectDelete(0, lblPrefix + "VoteBar_Empty"); ObjectDelete(0, lblPrefix + "Txt_VoteB"); ObjectDelete(0, lblPrefix + "Txt_VoteS");
         return;
      }

      string mainSigStr = "WAITING";
      string subSigStr = "Scanning Market";
      color sigBgCol = C_BG_Main;
      color sigTxtCol = C_Text_Mute;

      if (finalBBB) { mainSigStr = "BUY SIGNAL"; subSigStr = "Strong Confirmation"; sigBgCol = C_Success; sigTxtCol = clrWhite; }
      else if (finalSSS) { mainSigStr = "SELL SIGNAL"; subSigStr = "Strong Confirmation"; sigBgCol = C_Danger; sigTxtCol = clrWhite; }
      else if (finalsigB) { mainSigStr = "PRE-BUY"; subSigStr = "Wait for Trigger"; sigBgCol = C_BG_Header; sigTxtCol = C_Success; }
      else if (finalsigS) { mainSigStr = "PRE-SELL"; subSigStr = "Wait for Trigger"; sigBgCol = C_BG_Header; sigTxtCol = C_Danger; }
      else if (semi_is_slowing_down && finalsigB) { mainSigStr = "SLOW DOWN"; subSigStr = "Preparing Buy..."; sigBgCol = C_Warning; sigTxtCol = C_BG_Main; }
      else if (semi_is_slowing_up && finalsigS) { mainSigStr = "SLOW UP"; subSigStr = "Preparing Sell..."; sigBgCol = C_Warning; sigTxtCol = C_BG_Main; }

      int sigBoxY = y + 45;
      CPEAi_GUI::CreateRect(lblPrefix + "SigBox", x + 10, sigBoxY, w - 20, 50, sigBgCol);
      CPEAi_GUI::CreateLabel(lblPrefix + "SigMain", x + w / 2, sigBoxY, mainSigStr, 14, sigTxtCol, true, ANCHOR_UPPER);
      CPEAi_GUI::CreateLabel(lblPrefix + "SigSub", x + w / 2, sigBoxY + 25, subSigStr, 8, sigTxtCol, false, ANCHOR_UPPER);

      int div1Y = sigBoxY + 60;
      CPEAi_GUI::CreateRect(lblPrefix + "Div_1", x + 15, div1Y, w - 30, 1, C_BG_Header);

      int startDataY = div1Y + 20;
      int col1X = x + (w / 2) / 2;
      int col2X = x + (w / 4) * 3;

      CPEAi_GUI::CreateLabel(lblPrefix + "L_Vote", (x + w / 2), startDataY - 14, "VOTE PRESSURE", 9, C_Text_Mute, false, ANCHOR_UPPER);
      DrawVoteProgressBar(lblPrefix, x + 20, startDataY + 10, w - 30, 16, buyCount, sellCount);
      ObjectDelete(0, lblPrefix + "V_Vote");

      int row2Y = startDataY + 16 + 15;
      int row3Y = row2Y + 38;
      int row4Y = row3Y + 38;

      string trendStr = (buyCount > sellCount) ? "BULLISH" : (sellCount > buyCount) ? "BEARISH" : "NEUTRAL";
      color trendCol = (buyCount > sellCount) ? C_Success : (sellCount > buyCount) ? C_Danger : C_Text_Mute;
      CPEAi_GUI::CreateLabel(lblPrefix + "L_Trend", col1X, row2Y, "TREND FLOW", 7, C_Text_Mute, false, ANCHOR_UPPER);
      CPEAi_GUI::CreateLabel(lblPrefix + "V_Trend", col1X, row2Y + 12, trendStr, 9, trendCol, true, ANCHOR_UPPER);

      double absIntensity = MathAbs(intensity_down);
      string intDir = (delta > delta_1) ? "▲" : "▼";
      color intCol = (absIntensity >= 0.3) ? (delta > delta_1 ? C_Success : C_Danger) : C_Text_Mute;
      CPEAi_GUI::CreateLabel(lblPrefix + "L_Int", col2X, row2Y, "INTENSITY", 7, C_Text_Mute, false, ANCHOR_UPPER);
      CPEAi_GUI::CreateLabel(lblPrefix + "V_Int", col2X, row2Y + 12, DoubleToString(absIntensity, 2) + " " + intDir, 9, intCol, true, ANCHOR_UPPER);

      color baseRangeCol = (baseRange > 0.9999) ? ((buyCount > sellCount) ? C_Success : (sellCount > buyCount ? C_Danger : C_Warning)) : C_Text_Mute;
      CPEAi_GUI::CreateLabel(lblPrefix + "L_Base", col1X, row3Y, "BASE RANGE", 7, C_Text_Mute, false, ANCHOR_UPPER);
      CPEAi_GUI::CreateLabel(lblPrefix + "V_Base", col1X, row3Y + 12, DoubleToString(baseRange, 4), 9, baseRangeCol, true, ANCHOR_UPPER);

      CPEAi_GUI::CreateLabel(lblPrefix + "L_Cdl", col2X, row3Y, "CANDLE", 7, C_Text_Mute, false, ANCHOR_UPPER);
      CPEAi_GUI::CreateLabel(lblPrefix + "V_Cdl", col2X, row3Y + 12, is_abnormal ? "ABNORMAL ⚠" : "NORMAL", 8, is_abnormal ? C_Warning : C_Success, true, ANCHOR_UPPER);

      color mktCol = !isTimeAllowed ? C_Text_Mute : (newsBlock ? C_Danger : C_Success);
      string mktStatus = !isTimeAllowed ? "CLOSED" : (newsBlock ? "NEWS FLT" : "OPEN");
      CPEAi_GUI::CreateLabel(lblPrefix + "L_Mkt", col1X, row4Y, "MARKET", 7, C_Text_Mute, false, ANCHOR_UPPER);
      CPEAi_GUI::CreateLabel(lblPrefix + "V_Mkt", col1X, row4Y + 12, mktStatus, 8, mktCol, true, ANCHOR_UPPER);
      
      // [ADDED] Run Count Display
      CPEAi_GUI::CreateLabel(lblPrefix + "L_Run", col2X, row4Y, "RUN (B/S)", 7, C_Text_Mute, false, ANCHOR_UPPER);
      CPEAi_GUI::CreateLabel(lblPrefix + "V_Run", col2X, row4Y + 12, IntegerToString(runB) + " / " + IntegerToString(runS), 9, C_Text_Main, true, ANCHOR_UPPER);

      int div2Y = row4Y + 40;
      CPEAi_GUI::CreateRect(lblPrefix + "Div_2", x + 15, div2Y, w - 30, 1, C_BG_Header);
      int statY = div2Y + 10;

      if (balance == 0) {
         CPEAi_GUI::CreateLabel(lblPrefix + "S1", x + 15, statY, "Balance:", 8, C_Text_Mute);
         CPEAi_GUI::CreateLabel(lblPrefix + "S1V", x + w - 15, statY, "$" + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2), 8, C_Text_Main, true, ANCHOR_RIGHT_UPPER);
         CPEAi_GUI::CreateLabel(lblPrefix + "S2", x + 15, statY + 18, "Risk Mode:", 8, C_Text_Mute);
         CPEAi_GUI::CreateLabel(lblPrefix + "S2V", x + w - 15, statY + 18, riskModeStr, 8, C_Warning, false, ANCHOR_RIGHT_UPPER);
      } else {
         int totalTrades = wins + losses;
         double winRate = (totalTrades > 0) ? ((double)wins / totalTrades) * 100.0 : 0.0;
         CPEAi_GUI::CreateLabel(lblPrefix + "S1", x + 15, statY, "Win Rate:", 8, C_Text_Mute);
         CPEAi_GUI::CreateLabel(lblPrefix + "S1V", x + w - 15, statY, DoubleToString(winRate, 1) + "% (" + IntegerToString(wins) + "/" + IntegerToString(losses) + ")", 8, (winRate >= 50 ? C_Success : C_Danger), true, ANCHOR_RIGHT_UPPER);
         CPEAi_GUI::CreateLabel(lblPrefix + "S2", x + 15, statY + 18, "Net Profit:", 8, C_Text_Mute);
         CPEAi_GUI::CreateLabel(lblPrefix + "S2V", x + w - 15, statY + 18, "$" + DoubleToString(netProfit, 2), 8, (netProfit >= 0 ? C_Success : C_Danger), true, ANCHOR_RIGHT_UPPER);
      }
   }
};

// ==========================================
// 5. EA CONTROL PANEL
// ==========================================
class CPEAi_ControlPanel {
public:
   static void Create(string prefix, int x, int y, bool autoMode, bool minimized) {
      int w = 240;
      int startY = y + 330;
      CPEAi_GUI::CreatePanelBG(prefix + "BG_Panel", x, startY, w, 130, C_BG_Panel);
      CPEAi_GUI::CreateFlatButton(prefix + "Btn_Auto", x + 5, startY + 5, w - 10, 35, autoMode ? "AUTO TRADING: ACTIVE ⚡" : "AUTO TRADING: OFF", autoMode ? C_Accent : C_Disabled, clrWhite);
      int row2_y = startY + 5 + 35 + 5;
      int half_w = (w - 15) / 2;
      CPEAi_GUI::CreateFlatButton(prefix + "Btn_Buy", x + 5, row2_y, half_w, 35, "BUY", C_Success, clrWhite);
      CPEAi_GUI::CreateFlatButton(prefix + "Btn_Sell", x + 5 + half_w + 5, row2_y, half_w, 35, "SELL", C_Danger, clrWhite);
      int row3_y = row2_y + 35 + 5;
      CPEAi_GUI::CreateFlatButton(prefix + "Btn_CloseAll", x + 5, row3_y, w - 10, 35, "CLOSE ALL POSITIONS", C_Warning, C_BG_Panel);
      int taskBarY = row3_y + 35 + 5;
      CPEAi_GUI::CreateFlatButton(prefix + "Btn_MasterMin", x, taskBarY, w, 20, "▲ HIDE", C_TaskBar, clrWhite, 10000);
   }

   static void UpdateVisibility(string prefix, bool minimized, int dashX, int dashY) {
      int period = minimized ? OBJ_NO_PERIODS : OBJ_ALL_PERIODS;
      ObjectSetInteger(0, prefix + "BG_Panel", OBJPROP_TIMEFRAMES, period);
      ObjectSetInteger(0, prefix + "Btn_Auto", OBJPROP_TIMEFRAMES, period);
      ObjectSetInteger(0, prefix + "Btn_Buy", OBJPROP_TIMEFRAMES, period);
      ObjectSetInteger(0, prefix + "Btn_Sell", OBJPROP_TIMEFRAMES, period);
      ObjectSetInteger(0, prefix + "Btn_CloseAll", OBJPROP_TIMEFRAMES, period);

      string minBtnName = prefix + "Btn_MasterMin";
      if (ObjectFind(0, minBtnName) >= 0) {
         ObjectSetInteger(0, minBtnName, OBJPROP_BACK, false);
         ObjectSetInteger(0, minBtnName, OBJPROP_ZORDER, 10000);
         if (minimized) {
            ObjectSetInteger(0, minBtnName, OBJPROP_XDISTANCE, dashX);
            ObjectSetInteger(0, minBtnName, OBJPROP_YDISTANCE, dashY + 35);
            ObjectSetString(0, minBtnName, OBJPROP_TEXT, "▼ SHOW CONTROL PANEL");
         } else {
            ObjectSetInteger(0, minBtnName, OBJPROP_XDISTANCE, dashX);
            ObjectSetInteger(0, minBtnName, OBJPROP_YDISTANCE, dashY + 330 + 5 + 35 + 5 + 35 + 5 + 35 + 5);
            ObjectSetString(0, minBtnName, OBJPROP_TEXT, "▲ HIDE");
         }
      }
   }
   
   static void UpdateButtons(string prefix, bool autoMode, double mbLot, double msLot) {
      if (autoMode) {
         ObjectSetString(0, prefix + "Btn_Auto", OBJPROP_TEXT, "AUTO TRADING: ACTIVE ⚡");
         ObjectSetInteger(0, prefix + "Btn_Auto", OBJPROP_BGCOLOR, C_Accent);
         ObjectSetInteger(0, prefix + "Btn_Buy", OBJPROP_BGCOLOR, C_Disabled);
         ObjectSetInteger(0, prefix + "Btn_Sell", OBJPROP_BGCOLOR, C_Disabled);
         ObjectSetString(0, prefix + "Btn_Buy", OBJPROP_TEXT, "---");
         ObjectSetString(0, prefix + "Btn_Sell", OBJPROP_TEXT, "---");
      } else {
         ObjectSetString(0, prefix + "Btn_Auto", OBJPROP_TEXT, "AUTO TRADING: PAUSED ⏸");
         ObjectSetInteger(0, prefix + "Btn_Auto", OBJPROP_BGCOLOR, C_Disabled);
         ObjectSetInteger(0, prefix + "Btn_Buy", OBJPROP_BGCOLOR, C_Success);
         ObjectSetInteger(0, prefix + "Btn_Sell", OBJPROP_BGCOLOR, C_Danger);
         ObjectSetString(0, prefix + "Btn_Buy", OBJPROP_TEXT, "BUY " + DoubleToString(mbLot, 2));
         ObjectSetString(0, prefix + "Btn_Sell", OBJPROP_TEXT, "SELL " + DoubleToString(msLot, 2));
      }
   }
};
//+------------------------------------------------------------------+