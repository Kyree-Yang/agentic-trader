<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 960 432" role="img" aria-label="Four Claude routines coordinate through the brokerage account as shared state; a local review writes the journal whose lessons flow back into the routine prompts weekly.">
  <defs>
    <marker id="a" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="__MUTED__"/>
    </marker>
    <marker id="aa" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="__ACCENT__"/>
    </marker>
  </defs>
  <rect x="0" y="0" width="960" height="432" fill="__BG__"/>
  <g font-family="-apple-system,'Segoe UI',Helvetica,Arial,sans-serif">

    <!-- time labels -->
    <g font-size="11" fill="__MUTED__" text-anchor="middle">
      <text x="132" y="30">9:20 ET</text>
      <text x="361" y="30">9:31–15:30 ET · hourly</text>
      <text x="590" y="30">15:55 ET</text>
      <text x="835" y="30">post-close</text>
    </g>

    <!-- cloud group -->
    <rect x="16" y="36" width="690" height="130" rx="8" fill="none" stroke="__BORDER__" stroke-dasharray="4 4"/>
    <text x="28" y="54" font-size="11" fill="__MUTED__">Claude Code cloud routines · Fable 5 · stateless sessions</text>
    <!-- local group -->
    <rect x="726" y="36" width="218" height="130" rx="8" fill="none" stroke="__BORDER__" stroke-dasharray="4 4"/>
    <text x="738" y="54" font-size="11" fill="__MUTED__">local Mac · launchd</text>

    <!-- stage boxes -->
    <g>
      <rect x="32" y="64" width="200" height="88" rx="6" fill="__CARD__" stroke="__BORDER__"/>
      <text x="132" y="90" font-size="13" font-weight="600" fill="__TEXT__" text-anchor="middle">Premarket Review</text>
      <text x="132" y="112" font-size="11" fill="__MUTED__" text-anchor="middle">research + catalyst vetting</text>
      <text x="132" y="130" font-size="11" fill="__MUTED__" text-anchor="middle">no order authority</text>

      <rect x="256" y="64" width="210" height="88" rx="6" fill="__CARD__" stroke="__BORDER__"/>
      <text x="361" y="90" font-size="13" font-weight="600" fill="__TEXT__" text-anchor="middle">Intraday Trader</text>
      <text x="361" y="112" font-size="11" fill="__MUTED__" text-anchor="middle">hourly + 10:01 ORB window</text>
      <text x="361" y="130" font-size="11" fill="__MUTED__" text-anchor="middle">sole order authority</text>

      <rect x="490" y="64" width="200" height="88" rx="6" fill="__CARD__" stroke="__BORDER__"/>
      <text x="590" y="90" font-size="13" font-weight="600" fill="__TEXT__" text-anchor="middle">Close Check</text>
      <text x="590" y="112" font-size="11" fill="__MUTED__" text-anchor="middle">overnight-hold decision</text>
      <text x="590" y="130" font-size="11" fill="__MUTED__" text-anchor="middle">new entries forbidden</text>

      <rect x="738" y="64" width="194" height="88" rx="6" fill="__CARD__" stroke="__BORDER__"/>
      <text x="835" y="90" font-size="13" font-weight="600" fill="__TEXT__" text-anchor="middle">Daily Review</text>
      <text x="835" y="112" font-size="11" fill="__MUTED__" text-anchor="middle">headless Claude · read-only</text>
      <text x="835" y="130" font-size="11" fill="__MUTED__" text-anchor="middle">audits rule compliance</text>
    </g>

    <!-- broker band -->
    <rect x="104" y="224" width="596" height="64" rx="6" fill="__CARD__" stroke="__BORDER__" stroke-width="1.5"/>
    <text x="120" y="250" font-size="13" font-weight="600" fill="__TEXT__">Robinhood agentic account</text>
    <text x="120" y="270" font-size="11" fill="__MUTED__">shared state: watchlist · positions · orders · GTC stops live at the exchange</text>

    <!-- neutral arrows -->
    <g stroke="__MUTED__" fill="none">
      <line x1="132" y1="152" x2="132" y2="220" marker-end="url(#a)"/>
      <line x1="305" y1="152" x2="305" y2="220" marker-end="url(#a)"/>
      <line x1="417" y1="220" x2="417" y2="158" marker-end="url(#a)"/>
      <line x1="590" y1="152" x2="590" y2="220" marker-end="url(#a)"/>
      <polyline points="700,250 790,250 790,160" marker-end="url(#a)"/>
      <line x1="880" y1="152" x2="880" y2="324" marker-end="url(#a)"/>
    </g>
    <g font-size="11" fill="__MUTED__">
      <text x="140" y="192">writes vetted watchlist</text>
      <text x="313" y="178">limit orders + GTC stops</text>
      <text x="425" y="205">reads state + candidates</text>
      <text x="598" y="190">sell / raise stops pre-bell</text>
      <text x="712" y="244">fills &amp; realized P&amp;L</text>
      <text x="872" y="310" text-anchor="end">writes journal + trades.csv</text>
    </g>

    <!-- journal box -->
    <rect x="726" y="330" width="218" height="76" rx="6" fill="__CARD__" stroke="__BORDER__"/>
    <text x="835" y="354" font-size="13" font-weight="600" fill="__TEXT__" text-anchor="middle">Journal &amp; PLAYBOOK</text>
    <text x="835" y="374" font-size="11" fill="__MUTED__" text-anchor="middle">rules tiered: verified / hypothesis</text>
    <text x="835" y="392" font-size="11" fill="__MUTED__" text-anchor="middle">daily reviews · trade log</text>

    <!-- lessons feedback loop (accent) -->
    <polyline points="726,368 80,368 80,174" fill="none" stroke="__ACCENT__" stroke-width="2" marker-end="url(#aa)"/>
    <text x="403" y="360" font-size="11.5" font-weight="600" fill="__ACCENT__" text-anchor="middle">lessons reflow into routine prompts (weekly, after real losses)</text>
  </g>
</svg>
