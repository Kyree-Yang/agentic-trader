// 重建 Campaign #1 逐小时账户净值曲线,输出明暗两版 SVG(GitHub 配色)
import { readFileSync, writeFileSync } from 'fs';

const raw = JSON.parse(readFileSync(process.argv[2], 'utf8'));
const bars = {}; // symbol -> [{t(ms of bar CLOSE), px}]
for (const r of raw.data.results) {
  bars[r.symbol] = r.bars.filter(b => !b.interpolated).map(b => ({
    t: Date.parse(b.begins_at) + 3600e3, px: parseFloat(b.close_price)
  }));
}

// 成交台账(UTC ms, symbol, qty 变化, 现金变化, 成交价)
const F = (s,t,sym,q,px,fee=0)=>({t:Date.parse(t),sym,q,px,cash:-q*px-fee,side:s});
const fills = [
  F('B','2026-08-17T14:33:55Z','HTHT', 10,46.0058), F('B','2026-08-17T14:33:56Z','LUNR', 24,20.4187),
  F('S','2026-08-18T13:30:00Z','LUNR',-24,19.28),   F('B','2026-08-18T14:33:40Z','AS',   14,34.0743),
  F('S','2026-08-18T15:21:20Z','AS',  -14,33.29),   F('B','2026-08-18T15:34:47Z','BBWI', 24,20.0387),
  F('S','2026-08-19T14:56:40Z','BBWI',-24,20.35),   F('B','2026-08-20T14:06:41Z','BMNR', 23,21.4785),
  F('S','2026-08-21T13:30:04Z','HTHT',-10,48.788),  F('B','2026-08-21T14:05:51Z','BJ',    5,95.6399),
  F('S','2026-08-21T19:33:11Z','BMNR',-23,22.6217,0.02), F('S','2026-08-24T17:47:51Z','BJ',-5,98.89),
  F('B','2026-08-25T14:34:13Z','KURA', 36,13.3876), F('S','2026-08-25T15:33:15Z','KURA',-36,13.8001),
];
const exits = [ // 平仓事件标注
  {t:'2026-08-18T13:30:00Z',label:'LUNR −$27'}, {t:'2026-08-18T15:21:20Z',label:'AS −$11'},
  {t:'2026-08-19T14:56:40Z',label:'BBWI +$7'},  {t:'2026-08-21T13:30:04Z',label:'HTHT +$28'},
  {t:'2026-08-21T19:33:11Z',label:'BMNR +$26'}, {t:'2026-08-24T17:47:51Z',label:'BJ +$16'},
  {t:'2026-08-25T15:33:15Z',label:'KURA +$15'},
].map(e=>({t:Date.parse(e.t),label:e.label}));

// 采样时间轴:各交易日开盘 13:30Z + 每根小时 bar 收盘时刻 + 全部成交时刻
const days = ['2026-08-17','2026-08-18','2026-08-19','2026-08-20','2026-08-21','2026-08-24','2026-08-25'];
const times = new Set(fills.map(f=>f.t));
for (const d of days) { times.add(Date.parse(d+'T13:30:00Z'));
  for (let h=15; h<=20; h++) times.add(Date.parse(d+`T${h}:00:00Z`)); }
const now = Date.parse('2026-08-25T16:35:00Z');
const ts = [...times].filter(t=>t<=now).sort((a,b)=>a-b);

function priceAt(sym, t) { // 最近已知价:优先 ≤t 的 bar 收盘,其次 ≤t 的成交价
  let p = null, pt = -1;
  for (const b of bars[sym]||[]) if (b.t<=t && b.t>pt) { p=b.px; pt=b.t; }
  for (const f of fills) if (f.sym===sym && f.t<=t && f.t>pt) { p=f.px; pt=f.t; }
  return p;
}
const pts = ts.map(t => {
  let cash = 1000, pos = {};
  for (const f of fills) if (f.t<=t) { cash += f.cash; pos[f.sym]=(pos[f.sym]||0)+f.q; }
  let eq = cash;
  for (const [s,q] of Object.entries(pos)) if (q>0.001) eq += q*priceAt(s,t);
  return { t, eq };
});
console.log('final equity:', pts[pts.length-1].eq.toFixed(2));

// x 映射:7 个交易日等宽,日内按 13:30–20:00Z 比例
const M = {l:64, r:24, top:28, bot:40}, W=960, H=360;
const plotW = W-M.l-M.r, plotH = H-M.top-M.bot, dayW = plotW/days.length;
const X = t => { const d = new Date(t).toISOString().slice(0,10); const i = days.indexOf(d);
  const frac = Math.min(1, Math.max(0, (t - Date.parse(d+'T13:30:00Z')) / (6.5*3600e3)));
  return M.l + i*dayW + frac*dayW; };
const yMin=940, yMax=1070;
const Y = v => M.top + (yMax-v)/(yMax-yMin)*plotH;

const line = pts.map((p,i)=>`${i?'L':'M'}${X(p.t).toFixed(1)},${Y(p.eq).toFixed(1)}`).join('');
const area = line + `L${X(pts[pts.length-1].t).toFixed(1)},${Y(yMin)}L${X(pts[0].t).toFixed(1)},${Y(yMin)}Z`;

function svg(c) {
  const grid = [950,975,1000,1025,1050].map(v=>
    `<line x1="${M.l}" y1="${Y(v)}" x2="${W-M.r}" y2="${Y(v)}" stroke="${c.border}" stroke-width="1"/>
     <text x="${M.l-8}" y="${Y(v)+4}" font-size="11" fill="${c.muted}" text-anchor="end">$${v.toLocaleString()}</text>`).join('');
  const seps = days.slice(1).map((_,i)=>
    `<line x1="${M.l+(i+1)*dayW}" y1="${M.top}" x2="${M.l+(i+1)*dayW}" y2="${H-M.bot}" stroke="${c.border}" stroke-dasharray="2 5"/>`).join('');
  const dayLabels = days.map((d,i)=>
    `<text x="${M.l+i*dayW+dayW/2}" y="${H-14}" font-size="11" fill="${c.muted}" text-anchor="middle">${d.slice(5).replace('-','/')}</text>`).join('');
  const dots = exits.map(e=>{ const p = pts.find(p=>p.t===e.t); const neg = e.label.includes('−') || e.label.startsWith('KURA');
    return `<circle cx="${X(p.t).toFixed(1)}" cy="${Y(p.eq).toFixed(1)}" r="3.5" fill="${c.accent}" stroke="${c.bg}" stroke-width="2"/>
      <text x="${X(p.t).toFixed(1)}" y="${(Y(p.eq)+(neg?20:-11)).toFixed(1)}" font-size="10.5" fill="${c.muted}" text-anchor="middle">${e.label}</text>`;}).join('');
  const last = pts[pts.length-1];
  return `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${W} ${H}" role="img" aria-label="Campaign #1 account equity, hourly, Aug 17-25 2026: dip to $954 on Aug 18, recovery and steady climb to the $1,050 goal, finishing at $1,054.">
<rect width="${W}" height="${H}" fill="${c.bg}"/>
<g font-family="-apple-system,'Segoe UI',Helvetica,Arial,sans-serif">
${grid}${seps}
<line x1="${M.l}" y1="${Y(1050)}" x2="${W-M.r}" y2="${Y(1050)}" stroke="${c.muted}" stroke-dasharray="5 4" stroke-width="1.2"/>
<text x="${M.l+6}" y="${Y(1050)-6}" font-size="11" fill="${c.muted}">goal $1,050</text>
<text x="${M.l+6}" y="${Y(1000)-6}" font-size="11" fill="${c.muted}">baseline $1,000</text>
<path d="${area}" fill="${c.accent}" opacity="0.08"/>
<path d="${line}" fill="none" stroke="${c.accent}" stroke-width="2" stroke-linejoin="round"/>
${dots}
<circle cx="${X(last.t).toFixed(1)}" cy="${Y(last.eq).toFixed(1)}" r="4" fill="${c.accent}" stroke="${c.bg}" stroke-width="2"/>
<text x="${(X(last.t)-8).toFixed(1)}" y="${(Y(last.eq)-14).toFixed(1)}" font-size="12.5" font-weight="700" fill="${c.accent}" text-anchor="end">$1,054 · GOAL ✓</text>
${dayLabels}
</g></svg>`;
}
const dark  = {bg:'#0d1117', border:'#21262d', muted:'#8b949e', accent:'#58a6ff'};
const light = {bg:'#ffffff', border:'#eaeef2', muted:'#57606a', accent:'#0969da'};
writeFileSync('equity-dark.svg', svg(dark));
writeFileSync('equity-light.svg', svg(light));
console.log('SVGs written');
