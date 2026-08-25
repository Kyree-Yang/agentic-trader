# Trading System Charter(操作准则与计划书)

本文件是整个自动交易项目的**权威计划书**:系统架构、全部交易规则、运维手册、数据流。规则若有变更,先改这里,再同步到云端 routine(见 `system/` 目录的 prompt 副本)。

_最后更新:2026-08-16(Campaign #1 开始前夜)_

---

## 1. 使命与边界

- **账户**:Robinhood "Agentic"(专用实验账户),独立实验账户,与其他三个账户完全隔离(agent 对其他账户只读,严禁交易)
- **Campaign #1**:2026-08-17 → 2026-08-28,基线 $1,000,目标 **$1,050(+5%)**
- **长期使命**:每期战役积累实战数据 → 周复盘沉淀规则 → 数月后形成一套被自己账户数据验证过的 trading skills(见 `lessons/PLAYBOOK.md`)
- 用户已知晓并接受风险;所有交易由 AI(Claude Fable 5)全权自动执行

## 2. 系统架构

```
盘前 9:20 ET                     盘中 9:31–15:30 ET(每小时)          收盘后 16:47 ET
┌─────────────────────┐         ┌─────────────────────┐         ┌─────────────────────┐
│ Premarket Review     │ 候选股  │ Agentic Trader       │  成交   │ Daily Review(本地)  │
│ (云端 routine, Fable)│ ──────▶ │ (云端 routine, Fable)│ ──────▶ │ (launchd + headless) │
│ 只调研,不下单         │watchlist│ 唯一有下单权的组件     │  数据   │ 只读,写日志          │
└─────────────────────┘"Agentic └─────────────────────┘         └─────────────────────┘
                       Candidates"                                       │
        跨组件状态传递:Robinhood watchlist(候选池)+ 账户订单/持仓(事实源) ▼
                                                              ~/trading-journal/
                                                        (trades / journal / lessons)
```

- **云端 routine ID**(管理入口 https://claude.ai/code/routines):
  - Trader `<TRIGGER_TRADER>`(`30 13-19 * * 1-5` UTC,美东 9:31–15:30 每小时)
  - Premarket `<TRIGGER_PREMARKET>`(`20 13 * * 1-5` UTC,美东 9:20)
  - **10:01 入场窗** `<TRIGGER_1001>`(`1 14 * * 1-5` UTC)——专攻 opening-range 突破窗口(9:45–10:30)的入场评估
  - **15:55 收盘检查** `<TRIGGER_CLOSE>`(`55 19 * * 1-5` UTC)——只做隔夜持仓决策(动量衰竭即离场、财报临近必卖、盈利仓止损上移至保本以上),禁止开新仓
- **Robinhood connector**:claude.ai custom connector,UUID `<CONNECTOR_UUID>`,URL `https://agent.robinhood.com/mcp/trading`,工具权限 Always allow
- **本地复盘**:launchd `com.<USER>.trading-daily-review`(周一至五 13:47 PT),脚本 `bin/daily-review.sh`,只授权只读工具(下单类工具刻意不放行)
- 云端 session 无长期记忆,规则全部写死在 prompt 里;prompt 逐字副本存于 `system/`

## 3. 交易规则(当前生效版)

### 硬性风控(优先级最高,不可协商)
1. 最多 2 个并发仓位;单仓成本 ≤ **$500**
2. 每次入场立即挂保护性止损单:优先结构位(opening range 低点/最近支撑),上限 **-8%**;每轮运行核查止损单存在,缺失即补
3. 止盈 **+12~15%**(挂 limit sell,或涨幅超 +12% 且动量衰竭时市价了结)
4. **KILL SWITCH**:净值 ≤ **$800** → 撤所有单、市价清仓、永久停止交易并报告 HALTED
5. **GOAL-LOCK**:净值 ≥ **$1,050** → 战役获胜,停止开新仓,持仓止损收至保本位以上有序退出,守住胜局到 8/28
6. PDT:滚动 5 交易日内 day trade ≤ 3 次;以 1–3 天 swing 为主;当日买入的票卖出前必须先数 day trade 次数
7. 不超购买力;入场用 limit 单;流动性差的票禁止市价买入
8. 8/28 当日全部清仓,不开新仓;8/28 之后不再交易

### 选股与入场(catalyst + momentum)
- 只做有**可验证 catalyst** 的标的(财报 beat、FDA、大合同、上调评级、M&A),WebSearch 核实;查无 catalyst 的 gap 不碰
- 质量 gap:+3~10%(大盘股 1–2% 可),RVOL ≥ 2x,>~15% 视为追高放弃
- 流动性:日均量 >1M 股,价格 $2–$100
- 开盘 9:31 轮只做点差紧的 A+ 机会;常规入场等 opening range 突破 + 放量确认
- 空仓合法:+5% 目标下,一笔好交易胜过五笔平庸交易

### Campaign #1 事件日历(盘前 routine 每日用新数据复核)
- **第一周 = 进攻窗**:零售财报潮 HD 8/18 早、TGT/LOW/EL/ADI 8/19 早、WMT/BABA/DE/NTES 8/20 早、ROST 8/20 晚;只做财报公布后的反应,不持仓赌财报;8/19 14:00 ET FOMC 纪要,当天 14:30 轮先看市场反应
- **第二周 = 风险墙**:NVDA 8/26 盘后、PCE 8/26–28(日期待核)、Jackson Hole 8/27 开幕(新 Fed 主席 Warsh 首秀);**8/26 10:30 后禁开新仓,8/26 收盘前 100% 现金,8/27–28 空仓**
- 宏观基调:指数历史高位 + 7 月零售 -0.6% + 消费者信心 51.0 + PCE 反弹至 3.5% 预期 → 下行风险不对称,尊重它

## 4. 数据流与存档

| 数据 | 位置 | 写入方 |
|---|---|---|
| 成交记录(事实源) | Robinhood(get_equity_orders / get_pnl_trade_history) | 券商 |
| 本地成交存档 | `trades/YYYY-MM-DD.csv` | 每日复盘任务 |
| 每日复盘 | `journal/YYYY-MM-DD.md` | 每日复盘任务 |
| 云端简报存档 | `briefings/` | **需人工归档**:云端运行报告存于 claude.ai 各 run session,和 Claude 对话时让它拉取归档(已知短板,见 §6) |
| 规则手册(结晶) | `lessons/PLAYBOOK.md` | 周复盘时更新 |
| 云端 prompt 副本 | `system/*.md` | 每次改 routine 时同步 |
| 长期记忆(跨会话) | Claude memory(robinhood-agentic-trading) | Claude |

## 5. 复盘制度

- **每日**(自动):当日成交 + 得失分析 + 教训 1–3 条;核查 agent 是否守规则(止损单齐全性、报告与实际订单一致性),异常打 ⚠️ ALERT
- **每周六**(与 Claude 一起,人工触发):胜率 / 盈亏比 / 最大回撤 / 规则遵守率;把结论写入 PLAYBOOK——规则三档制:**[验证]**(有本账户数据支持)/ **[假设]**(调研而来,待检验)/ **[废弃]**(被证伪,留作反面教材)
- **教训回流**(FinMem 分层记忆思想):周复盘后,把新升 [验证] 或新 [废弃] 的规则精简成几行,同步进两个云端 routine 的 prompt——云端 agent 无记忆,这是它们获得"长期经验"的唯一通道
- **每战役结束**:完整复盘,评估框架本身;决定下一战役的目标与规则修订

## 6. 运维手册(Runbook)

- **看运行状态/简报**:https://claude.ai/code/routines(两个 routine 的所有 run 记录)
- **暂停/停用**:同上页面 toggle;或让 Claude 用 RemoteTrigger update `enabled: false`
- **改规则**:先改本 CHARTER → 让 Claude 同步云端 prompt → 更新 `system/` 副本
- **本地复盘没跑**:查 `bin/daily-review.log`;launchd 状态 `launchctl list | grep trading-daily-review`
- **战役结束后(8/28)**:停用两个云端 routine;launchd 任务可保留(无交易时只写状态快照)或 `launchctl bootout gui/$UID ~/Library/LaunchAgents/com.<USER>.trading-daily-review.plist`
- **Token 消耗**:云端约 0.8–1.1M/交易日 + 本地复盘约 50k/日(Max plan 可承受;若吃紧,可把 routine 改跑 Sonnet)
- **已知短板**:① 云端简报不会自动落盘到 `briefings/`,需在对话中让 Claude 归档;② 云端 agent 之间只靠 watchlist 和账户状态传递信息,无共享文本记忆;③ launchd 任务在 Mac 关机/睡眠时段不执行(醒来不补跑)

## 7. 变更日志

- 2026-08-16:系统建成(双 routine + 本地复盘);注资 $400→$1,000;目标从 +$100 两次修订至 **+$50**;新增 GOAL-LOCK;完成周日全链路测试(connector、权限、headless 复盘均通过)
- 2026-08-16(晚):完成领域调研(`lessons/research-notes.md`),吸收 TradingAgents 的 **BEAR-CASE VETO**(入场前强制空头论证)与 TradingGroup 的**每日自省行**进交易 prompt;确立"教训回流"制度(§5);建立 CHARTER 与 `system/` prompt 副本
- 2026-08-19:评估加频方案,结论"全面加频负期望,手术式加点正期望"。新增两个定点 routine:**10:01 ET 入场窗**(填补 ORB 黄金窗口盲区)与 **15:55 ET 收盘检查**(隔夜决策移到贴近收盘,直接回应 LUNR 教训;禁开新仓)。日消耗 8→10 次运行(约 +200k tokens/日)
- 2026-08-18:首次实亏复盘(-4.6%:LUNR -$27.33 隔夜跳空、AS -$10.98 贴身止损)。三条教训回流云端 prompt:**止损距离下限(≥1.5× 当日 5min 波幅)**、**隔夜 gap 风险评估**、**risk-off 过滤(指数日内 -1% 停开新仓)**;修复本地复盘任务的睡眠唤醒 DNS 竞态(nslookup 重试);补记 8/17–8/18 journal 与 trades
