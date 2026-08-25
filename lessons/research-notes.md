# Agentic Trading 领域调研笔记(2026-08-16)

对现存 LLM 交易框架/实践的调研,以及我们吸收了什么、为什么不吸收其余部分。

## 学术/开源框架

| 框架 | 核心机制 | 报告效果 | 我们的吸收 |
|---|---|---|---|
| [TradingAgents](https://github.com/TauricResearch/TradingAgents)(TauricResearch,ICLR 评审中) | 模拟对冲基金:分析师团队 + **Bull/Bear 研究员辩论** + 风控团队 + 交易员 | 累计收益、Sharpe、最大回撤全面优于基线 | ✅ **BEAR-CASE VETO**:入场前强制写出最强空头论点,空头占优或五五开就放弃(单 agent 内化辩论,不加轮询成本) |
| [FinMem](https://github.com/pipiku915/FinMem-LLM-StockTrading)(arXiv 2311.13743) | **分层记忆**(短期行情/中期事件/长期教训分层供给)+ 角色设定 | 股票/基金实盘数据集上领先算法基线 | ✅ **教训回流机制**:周复盘把 PLAYBOOK 升为 [验证] 的规则精简后同步进云端 prompt(云端 agent 本身无记忆,这是我们的"长期记忆层") |
| [TradingGroup](https://arxiv.org/pdf/2508.17565)(arXiv 2508) | 多 agent + **自反思模块** | — | ✅ 收盘简报强制一行 self-reflection("明天唯一要改的一件事") |
| [ContestTrade](https://arxiv.org/pdf/2508.00554)(arXiv 2508) | 内部竞赛机制(多策略竞争资金分配) | — | ❌ 不吸收:$1,000 账户不够分,多策略竞争徒增成本 |

## 实践侧(Claude + MCP 交易)

- [MindStudio: Claude Code Routines 交易 agent](https://www.mindstudio.ai/blog/how-to-build-ai-trading-agent-claude-code-routines):与我们架构几乎一致(routine + 结构化交易日志),验证了选型
- [Robinhood agentic MCP 实测批评](https://medium.com/@austin-starks/i-just-tried-robinhoods-alleged-agentic-trading-i-am-not-impressed-33d3725a23e0):已知坑——localhost OAuth、无 crypto、无 options spread、文档为零;我们绕开的方式:claude.ai connector + 云端 routine(不需要电脑常开,别人的主要痛点)
- [ryandoser: Robinhood + Claude 交易 agent](https://ryandoser.com/ai-trading-agent-robinhood/)、[Medium: Claude 直连券商](https://medium.com/@0xnakamura/claude-can-now-trade-directly-in-your-brokerage-heres-how-it-works-75bed095a60e):均为单 agent 单 prompt 全包;我们的盘前/盘中/复盘三段分工 + watchlist 交接是更进一步的结构

## 保留判断(不盲从)

- 学术框架的回测优势 ≠ 实盘小账户可复制:它们的基线周期长、资金量大、无 PDT 约束;对我们最有迁移价值的是**机制**(辩论、记忆、反思),不是它们的收益数字
- 多 agent 数量不是越多越好:每加一个 agent 就加一份 token 成本和一致性风险;我们保持"3 段式 + watchlist 交接"的最小结构,机制内化到 prompt 里
