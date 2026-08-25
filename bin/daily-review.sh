#!/bin/zsh
# 每交易日收盘后自动复盘:拉当日成交与 P&L,写入 trading-journal
# 由 launchd 调用(周一至五 13:47 PT ≈ 16:47 ET)。日志: bin/daily-review.log
export PATH="~/.local/bin:/usr/local/bin:/usr/bin:/bin"
cd ~/trading-journal || exit 1

TODAY=$(TZ=America/New_York date +%Y-%m-%d)

PROMPT="今天是 ${TODAY}(美东)。你在 ~/trading-journal 目录下,请先读 README.md 了解日志库结构,然后为 Robinhood 账户 <ACCOUNT_ID> 做当日收盘复盘:
1. 用 get_equity_orders 拉当日全部订单(含已成交/已取消),用 get_pnl_trade_history / get_realized_pnl 拉当日已实现盈亏,用 get_portfolio + get_equity_positions 拉收盘后账户快照。
2. 把当日每笔成交追加写入 trades/${TODAY}.csv(按 README 的列定义;当日无成交则不建文件)。
3. 写 journal/${TODAY}.md:账户净值与相对 \$1000 基线的累计盈亏、当日每笔交易的得失分析(入场质量、止损/止盈执行、是否遵守 playbook 规则)、当日教训(1-3 条,具体可执行)。若当日无交易,简短记录账户状态和'无交易'原因即可。
4. 只做记录与分析,不下任何订单。若发现严重异常(持仓无止损单、账户接近 \$800 kill switch),在 journal 开头用 ⚠️ ALERT 标出。"

# Mac 从睡眠唤醒后网络可能未就绪:最多等 5 分钟直到 DNS 可用
for i in {1..10}; do
  if /usr/bin/nslookup api.anthropic.com >/dev/null 2>&1; then break; fi
  sleep 30
done

ALLOWED="Read,Write,Edit,Glob,Grep,ToolSearch,mcp__robinhood-trading__get_equity_orders,mcp__robinhood-trading__get_pnl_trade_history,mcp__robinhood-trading__get_realized_pnl,mcp__robinhood-trading__get_portfolio,mcp__robinhood-trading__get_equity_positions,mcp__robinhood-trading__get_equity_quotes,mcp__claude_ai_Robinhood__get_equity_orders,mcp__claude_ai_Robinhood__get_pnl_trade_history,mcp__claude_ai_Robinhood__get_realized_pnl,mcp__claude_ai_Robinhood__get_portfolio,mcp__claude_ai_Robinhood__get_equity_positions,mcp__claude_ai_Robinhood__get_equity_quotes,mcp__robinhood-trading__get_equity_historicals,mcp__claude_ai_Robinhood__get_equity_historicals,mcp__robinhood-trading__get_earnings_results,mcp__claude_ai_Robinhood__get_earnings_results"
LOG=~/trading-journal/bin/daily-review.log

# 失败(API Error / 空输出)则重试,间隔 5 分钟,最多 3 次;失败必须留下 FAILED 记录,不许静默
for attempt in 1 2 3; do
  OUT=$(echo "$PROMPT" | claude -p --model claude-fable-5 --allowedTools "$ALLOWED" 2>&1)
  RC=$?
  echo "$OUT" >> "$LOG"
  if [ $RC -eq 0 ] && [ -n "$OUT" ] && ! echo "$OUT" | grep -q "API Error"; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] daily-review OK (attempt $attempt)" >> "$LOG"
    exit 0
  fi
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] daily-review attempt $attempt FAILED (rc=$RC)" >> "$LOG"
  sleep 300
done
echo "[$(date '+%Y-%m-%d %H:%M:%S')] daily-review FAILED after 3 attempts — 需人工补记当日 journal" >> "$LOG"
exit 1
