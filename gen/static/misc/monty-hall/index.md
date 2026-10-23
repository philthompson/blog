[//]: # (gen-title: Monty Hall - philthompson.me)

[//]: # (gen-keywords: monty hall, problem, paradox, simulator, probability, game theory)

[//]: # (gen-description: JavaScript app for trying the Monty Hall game)

[//]: # (gen-meta-end)

<script src="../p5-v1.9.0.min.js"></script>

<style>
#mh-app{--bg:#16100e;--bg2:#2c1f19;--text:#f3e6d3;--muted:#b9a58c;--accent:#e9a84c;--accent-text:#1b130f;--frame:#3d2b22;--inside:#0b0706;--door-1:#7a4a32;--door-2:#7a4a32;--door-3:#7a4a32;--num:#f3d9a8;--knob:#e9c46a;--spot:rgba(255,214,150,.16);--beam:rgba(255,220,160,.15);--pool:rgba(255,215,150,.3);--light-blend:screen;--title-font:Georgia,"Times New Roman",serif;--body-font:Georgia,"Times New Roman",serif;--door-r:6px 6px 2px 2px;--door-ms:.9s;--dw:clamp(78px,24vw,170px);position:relative;isolation:isolate;box-sizing:border-box;margin:0 0 16px;padding:24px 16px 14px;border-radius:14px;overflow:hidden;text-align:center;font-family:var(--body-font);color:var(--text);background:radial-gradient(ellipse 80% 60% at 50% 35%,var(--bg2),var(--bg) 72%);transition:background .4s,color .4s}
#mh-app *{box-sizing:border-box}
#mh-app [hidden]{display:none!important}
#mh-app:not(.mh-show-opts) .mh-opt{display:none!important}
#mh-app>:not(.mh-space):not(.mh-light):not(dialog){position:relative;z-index:1}
#mh-app .mh-space{position:absolute;inset:0;z-index:0;display:none;overflow:hidden;pointer-events:none}
#mh-app .mh-space canvas{display:block}
#mh-app .mh-light{position:absolute;left:0;top:0;z-index:2;pointer-events:none;mix-blend-mode:var(--light-blend);opacity:0;transition:opacity .6s}
#mh-app .mh-light.mh-on{opacity:1}
#mh-app .mh-beam{transform-origin:50% 0;clip-path:polygon(40% 0,60% 0,100% 100%,0 100%);-webkit-mask-image:linear-gradient(to right,transparent,#000 35%,#000 65%,transparent);mask-image:linear-gradient(to right,transparent,#000 35%,#000 65%,transparent);background:linear-gradient(to bottom,transparent 0%,var(--beam) 25%,var(--beam) 41.7%,color-mix(in srgb,var(--beam) 40%,transparent) 65%,transparent 100%)}
#mh-app .mh-pool{border-radius:50%;background:radial-gradient(closest-side,var(--pool),transparent)}
#mh-app .mh-title{display:inline-block;font-family:var(--title-font);font-size:clamp(2rem,7vw,3.2rem);font-weight:bold;line-height:1.15;margin:0 0 8px;padding:0;color:var(--accent);letter-spacing:.02em;text-shadow:0 0 22px var(--spot);border:0;background:none}
#mh-app .mh-title::before,#mh-app .mh-title::after{display:none}
#mh-app .mh-bulbs{position:absolute;inset:-11px;display:none;pointer-events:none}
#mh-app .mh-bulbs i{position:absolute;width:9px;height:9px;margin:-4.5px 0 0 -4.5px;border-radius:50%;background:#6e4f0c;animation:mh-chase .6s steps(1,end) infinite}
@keyframes mh-chase{0%{background:#fff7c2;box-shadow:0 0 8px 2px #ffd23f}33.34%,100%{background:#6e4f0c;box-shadow:none}}
#mh-app .mh-msg{display:flex;align-items:center;justify-content:center;height:5.6rem;margin:0 auto 4px;max-width:34em;font-size:clamp(1rem,3.4vw,1.15rem);line-height:1.4}
#mh-app .mh-msg a{color:inherit;}
#mh-app .mh-msg small{font-size:.8em;white-space:nowrap}
#mh-app .mh-msg.mh-result{font-family:var(--title-font);font-size:clamp(1.5rem,5vw,2rem);font-weight:bold;color:var(--accent)}
#mh-app .mh-msg.mh-lose{color:var(--muted)}
#mh-app .mh-doors{position:relative;display:flex;justify-content:center;gap:clamp(10px,4vw,36px);padding:12px 0 4px}
#mh-app .mh-slot{position:relative;display:flex;flex-direction:column;align-items:center}
#mh-app .mh-slot::after{content:"";position:absolute;bottom:22px;left:50%;width:160%;height:36px;transform:translateX(-50%);background:radial-gradient(closest-side,var(--spot),transparent);pointer-events:none}
#mh-app .mh-slot:nth-child(3n+1){--door:var(--door-1)}
#mh-app .mh-slot:nth-child(3n+2){--door:var(--door-2)}
#mh-app .mh-slot:nth-child(3n){--door:var(--door-3)}
#mh-app .mh-peek{height:1.5em;font-size:.75rem;font-weight:bold;letter-spacing:.08em;text-transform:uppercase;color:var(--muted)}
#mh-app .mh-peek.mh-peek-cash{color:var(--accent)}
#mh-app .mh-door{position:relative;z-index:1;display:block;width:var(--dw);aspect-ratio:5/9;padding:0;margin:0;border:6px solid var(--frame);border-bottom-width:3px;border-radius:var(--door-r);background:var(--inside);perspective:900px;font:inherit;color:inherit;cursor:default;transition:box-shadow .3s,transform .2s}
#mh-app.mh-picking .mh-door{cursor:pointer}
#mh-app.mh-picking .mh-door:not(.mh-open):hover{transform:translateY(-4px);box-shadow:0 10px 28px var(--spot)}
#mh-app .mh-door:focus-visible{outline:3px solid var(--accent);outline-offset:4px}
#mh-app .mh-door.mh-picked{box-shadow:0 0 0 3px var(--accent),0 0 30px var(--accent)}
#mh-app .mh-behind{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;font-size:clamp(2.2rem,9vw,4rem);border-radius:var(--door-r)}
#mh-app .mh-cash .mh-behind{background:radial-gradient(circle,rgba(255,215,90,.45),transparent 65%)}
#mh-app .mh-panel{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;border-radius:var(--door-r);background:linear-gradient(90deg,color-mix(in srgb,var(--door) 65%,#000),var(--door) 12%,var(--door) 88%,color-mix(in srgb,var(--door) 65%,#000));box-shadow:inset 0 0 0 3px rgba(0,0,0,.18);transform-origin:left center;transition:transform var(--door-ms) cubic-bezier(.45,.05,.2,1)}
#mh-app .mh-panel::before,#mh-app .mh-panel::after{content:"";position:absolute;left:16%;right:16%;border:3px solid rgba(0,0,0,.2);border-radius:4px}
#mh-app .mh-panel::before{top:10%;bottom:58%}
#mh-app .mh-panel::after{top:58%;bottom:8%}
#mh-app .mh-open .mh-panel{transform:rotateY(-105deg)}
#mh-app .mh-num{position:relative;z-index:1;font-family:var(--title-font);font-weight:bold;font-size:clamp(1.4rem,6vw,2.6rem);color:var(--num);text-shadow:0 2px 0 rgba(0,0,0,.35)}
#mh-app .mh-knob{position:absolute;right:9%;top:52%;width:9%;aspect-ratio:1;border-radius:50%;background:var(--knob);box-shadow:0 1px 2px rgba(0,0,0,.5)}
#mh-app .mh-tag{height:1.5em;margin-top:8px;font-size:.8rem;font-weight:bold;letter-spacing:.08em;text-transform:uppercase;color:var(--accent)}
#mh-app .mh-doors.mh-many{display:grid;grid-template-columns:repeat(5,auto);justify-content:center;column-gap:clamp(6px,2vw,18px);row-gap:6px}
#mh-app .mh-many .mh-door{width:calc(var(--dw) * .5 - 7.3px);border-width:3px;border-bottom-width:2px}
#mh-app .mh-many .mh-door.mh-picked{box-shadow:0 0 0 2px var(--accent),0 0 16px var(--accent)}
#mh-app .mh-many .mh-peek{font-size:.6rem}
#mh-app .mh-many .mh-tag{font-size:.6rem;margin-top:4px}
#mh-app .mh-many .mh-num{font-size:clamp(.8rem,3vw,1.3rem)}
#mh-app .mh-many .mh-behind{font-size:clamp(1.1rem,4.5vw,2.1rem)}
#mh-app .mh-many .mh-panel::before,#mh-app .mh-many .mh-panel::after{border-width:2px}
#mh-app .mh-many .mh-slot::after{height:16px;bottom:16px}
#mh-app .mh-buttons{display:flex;flex-wrap:nowrap;gap:12px;justify-content:center;align-items:center;height:92px;margin:4px 0 10px}
#mh-app .mh-buttons .mh-btn{max-width:calc(50% - 6px)}
#mh-app .mh-btn{font:inherit;font-size:clamp(.85rem,2.6vw,1rem);line-height:1.2;padding:.7em 1.2em;margin:0;border-radius:999px;border:2px solid var(--accent);background:transparent;color:var(--text);cursor:pointer;transition:background .2s,color .2s,opacity .2s,box-shadow .2s}
#mh-app .mh-btn:hover:not(:disabled){background:var(--accent);color:var(--accent-text)}
#mh-app .mh-btn.mh-primary{background:var(--accent);color:var(--accent-text)}
#mh-app .mh-btn:disabled{cursor:default;opacity:.3}
#mh-app .mh-btn.mh-chosen:disabled{opacity:1;background:var(--accent);color:var(--accent-text);box-shadow:0 0 18px var(--spot)}
#mh-app .mh-btn.mh-chosen::before{content:"\2713  "}
#mh-app .mh-btn.mh-small{font-size:.8rem;padding:.4em .9em}
#mh-app .mh-stats-wrap{border-top:1px solid var(--frame);padding:14px 0 4px}
#mh-app .mh-view{display:flex;align-items:center;justify-content:center;gap:10px;font-size:.85rem;color:var(--muted)}
#mh-app .mh-view-label{cursor:pointer;user-select:none;-webkit-user-select:none;transition:color .2s}
#mh-app .mh-view-label.mh-active{color:var(--accent)}
#mh-app .mh-switch{position:relative;flex:none;width:46px;height:24px;padding:0;margin:0;border:2px solid var(--accent);border-radius:999px;background:transparent;cursor:pointer}
#mh-app .mh-switch:focus-visible{outline:2px solid var(--accent);outline-offset:3px}
#mh-app .mh-switch-thumb{position:absolute;top:2px;left:2px;width:16px;height:16px;border-radius:50%;background:var(--accent);transition:transform .25s}
#mh-app .mh-switch[aria-checked="true"] .mh-switch-thumb{transform:translateX(22px)}
#mh-app .mh-view-note{height:1.4em;margin:4px 0 6px;font-size:.72rem;color:var(--muted);visibility:hidden}
#mh-app .mh-view-note.mh-show{visibility:visible}
#mh-app .mh-untracked .mh-stats{opacity:.4}
#mh-app .mh-stats{display:flex;flex-wrap:wrap;justify-content:center;gap:12px 48px;margin-bottom:14px}
#mh-app .mh-stat h3{font-family:var(--title-font);font-size:1.05rem;margin:0 0 6px;color:var(--accent);border:0}
#mh-app .mh-stat p{margin:2px 0;color:var(--muted);font-variant-numeric:tabular-nums}
#mh-app .mh-footer{display:flex;flex-wrap:wrap;gap:10px 28px;justify-content:center;align-items:center;margin-top:14px;font-size:.85rem;color:var(--muted)}
#mh-app .mh-footer input{accent-color:var(--accent);margin:0 6px 0 0;vertical-align:middle}
#mh-app select{font:inherit;margin-left:6px;padding:.25em .5em;border-radius:6px;border:1px solid var(--frame);background:var(--bg2);color:var(--text)}
#mh-app .mh-credit{margin:18px 0 0;font-size:.7rem;color:var(--muted);opacity:.85}
#mh-app .mh-credit a{color:var(--accent)}
#mh-app .mh-opts-link{font:inherit;color:inherit;background:none;border:0;padding:0;margin:0 0 0 .2em;text-decoration:underline;cursor:pointer}
#mh-app dialog{border:2px solid var(--accent);border-radius:12px;background:var(--bg2);color:var(--text);font-family:var(--body-font);padding:20px 28px;text-align:center;max-width:90vw}
#mh-app dialog::backdrop{background:rgba(0,0,0,.6)}
#mh-app .mh-dlg-title{font-family:var(--title-font);font-size:1.3rem;font-weight:bold;margin:0 0 6px}
#mh-app .mh-dlg-sub{margin:0 0 16px;color:var(--muted)}
#mh-app .mh-dlg-btns{display:flex;gap:10px;justify-content:center}
#mh-app.mh-theme-2{--bg:#ece5da;--bg2:#faf6ef;--text:#3f3a4a;--muted:#7a7286;--accent:#d9785f;--accent-text:#fff;--frame:#d6cab8;--inside:#4a4453;--door-1:#8fb3a3;--door-2:#e2b07a;--door-3:#a99bc7;--num:#fff;--knob:#fff6e6;--spot:rgba(255,255,255,.75);--beam:rgba(255,255,255,.6);--pool:rgba(255,255,255,.8);--light-blend:soft-light;--title-font:ui-rounded,"SF Pro Rounded","Arial Rounded MT Bold","Varela Round","Nunito","Trebuchet MS",system-ui,sans-serif;--body-font:ui-rounded,"SF Pro Rounded","Arial Rounded MT Bold","Varela Round","Nunito","Trebuchet MS",system-ui,sans-serif;--door-r:999px 999px 6px 6px}
#mh-app.mh-theme-2 .mh-title{text-shadow:3px 3px 0 #f2c9a8}
#mh-app.mh-theme-2 .mh-btn{border-radius:12px}
#mh-app.mh-theme-2 .mh-panel::before{left:22%;right:22%;top:22%;border-radius:999px 999px 4px 4px}
#mh-app.mh-theme-3{--bg:#060c3a;--bg2:#1a2d9c;--text:#fff;--muted:#c9d2ff;--accent:#ffd23f;--accent-text:#060c3a;--frame:#ffd23f;--inside:#030620;--door-1:#e4002b;--door-2:#0b74d6;--door-3:#00a651;--num:#ffd23f;--knob:#ffd23f;--spot:rgba(255,240,180,.3);--beam:rgba(255,245,200,.18);--pool:rgba(255,240,190,.34);--title-font:Impact,Haettenschweiler,"Franklin Gothic Bold","Arial Black",sans-serif;--body-font:"Trebuchet MS",Arial,sans-serif;--door-r:4px}
#mh-app.mh-theme-3 .mh-title{margin:18px 0 22px;padding:.12em .55em;border-radius:12px;background:#c8102e;color:#fff;font-weight:normal;letter-spacing:.05em;text-transform:uppercase;text-shadow:3px 3px 0 #060c3a;box-shadow:0 0 0 6px var(--accent),0 0 34px var(--accent)}
#mh-app.mh-theme-3 .mh-bulbs{display:block}
#mh-app.mh-theme-3 .mh-num{font-weight:normal}
#mh-app.mh-theme-3 .mh-btn,#mh-app.mh-theme-3 .mh-stat h3,#mh-app.mh-theme-3 .mh-msg.mh-result{font-family:var(--title-font);font-weight:normal;letter-spacing:.04em}
#mh-app.mh-theme-3 .mh-btn{border-radius:8px;border-width:3px}
#mh-app.mh-theme-4{--bg:#000;--bg2:#0a0a14;--text:#ff5c7a;--muted:#ff5c7a;--accent:#ff5c7a;--accent-text:#000;--frame:#5ef2ff;--inside:#02020a;--door-1:#1d1450;--door-2:#122a55;--door-3:#2e1248;--num:#5ef2ff;--knob:#5ef2ff;--spot:rgba(140,170,255,.12);--beam:rgba(190,215,255,.16);--pool:rgba(190,215,255,.3);--title-font:"Arial Black","Arial Bold",Gadget,sans-serif;--body-font:"Arial Black","Arial Bold",Gadget,sans-serif;--door-r:4px;--door-ms:.45s;background:#000}
#mh-app.mh-theme-4 .mh-space{display:block}
#mh-app.mh-theme-4 .mh-title{text-transform:uppercase}
#mh-app.mh-theme-4 .mh-panel{transition-timing-function:cubic-bezier(.2,.8,.25,1)}
#mh-app.mh-theme-4 .mh-door:not(.mh-picked){box-shadow:0 0 12px rgba(94,242,255,.45)}
#mh-app.mh-theme-4 .mh-msg{font-size:.95rem}
#mh-app.mh-theme-4 .mh-msg.mh-result{font-size:clamp(1.5rem,5vw,2rem)}
#mh-app.mh-theme-4 .mh-title,#mh-app.mh-theme-4 .mh-msg,#mh-app.mh-theme-4 .mh-stat h3{font-weight:normal;text-shadow:none;color:transparent;background:linear-gradient(90deg,#ff4d4d,#ffb84d,#fff34d,#4dff88,#4de1ff,#8a6bff,#ff4dd8,#ff4d4d);background-size:200% 100%;-webkit-background-clip:text;background-clip:text;animation:mh-rainbow 9s linear infinite}
#mh-app.mh-theme-4 .mh-btn,#mh-app.mh-theme-4 .mh-tag,#mh-app.mh-theme-4 .mh-peek,#mh-app.mh-theme-4 .mh-num,#mh-app.mh-theme-4 .mh-stat p,#mh-app.mh-theme-4 .mh-view,#mh-app.mh-theme-4 .mh-view-note,#mh-app.mh-theme-4 .mh-footer,#mh-app.mh-theme-4 .mh-credit{font-weight:normal;animation:mh-hue 9s linear infinite}
@keyframes mh-rainbow{to{background-position:200% 0}}
@keyframes mh-hue{from{filter:hue-rotate(0deg)}to{filter:hue-rotate(360deg)}}
@media (max-width:520px){#mh-app{padding:20px 6px 12px;--dw:calc((100vw - 48px) / 3)}#mh-app .mh-doors{gap:8px}#mh-app .mh-door{border-width:3px;border-bottom-width:2px}}
</style>

<div id="mh-app" class="mh-theme-4">
<div id="mh-space" class="mh-space" aria-hidden="true"></div>
<h1 class="mh-title"><span class="mh-title-text">Monty Hall</span><span class="mh-bulbs" aria-hidden="true"></span></h1>
<p id="mh-msg" class="mh-msg"></p>
<div id="mh-doors" class="mh-doors"></div>
<div class="mh-buttons">
<button id="mh-keep" class="mh-btn" type="button" hidden>Keep Your Choice</button>
<button id="mh-switch" class="mh-btn" type="button" hidden>Switch My Choice to the Other Door</button>
<button id="mh-again" class="mh-btn mh-primary" type="button" hidden>Play Again</button>
</div>
<div class="mh-stats-wrap">
<div class="mh-view">
<span class="mh-view-label" data-v="visit">This Visit</span>
<button id="mh-view" class="mh-switch" type="button" role="switch" aria-checked="false" aria-label="Show all-time stats"><span class="mh-switch-thumb"></span></button>
<span class="mh-view-label" data-v="all">All Time</span>
</div>
<div id="mh-view-note" class="mh-view-note">Just for this browser.</div>
<div id="mh-stats" class="mh-stats"></div>
<button id="mh-reset" class="mh-btn mh-small mh-opt" type="button">Reset Stats</button>
</div>
<div class="mh-footer">
<label class="mh-opt"><input type="checkbox" id="mh-peek-cb" autocomplete="off">Show after initial pick</label>
<label class="mh-opt"><input type="checkbox" id="mh-ten-cb" autocomplete="off">10 doors</label>
<label class="mh-opt">Theme<select id="mh-theme"><option value="1">Theme 1</option><option value="2">Theme 2</option><option value="3">Theme 3</option><option value="4">Theme 4</option></select></label>
</div>
<p class="mh-credit">Created by Claude Opus 5.5, at the request and direction of Phil Thompson, in October 2026.  Built on <a href="https://p5js.org/">p5.js</a>.  <button id="mh-opts" class="mh-opts-link" type="button" aria-expanded="false">Options</button></p>
<dialog id="mh-confirm">
<form method="dialog">
<p class="mh-dlg-title">Are You Sure?</p>
<p class="mh-dlg-sub">This clears all saved stats.</p>
<div class="mh-dlg-btns"><button class="mh-btn" value="cancel" autofocus>Cancel</button><button class="mh-btn mh-primary" value="reset">Reset</button></div>
</form>
</dialog>
</div>

<script>
(() => {
	const $ = id => document.getElementById(id);
	const app = $('mh-app'), msg = $('mh-msg'), doorsEl = $('mh-doors');
	const keepBtn = $('mh-keep'), switchBtn = $('mh-switch'), againBtn = $('mh-again');
	const statsEl = $('mh-stats'), resetBtn = $('mh-reset'), dlg = $('mh-confirm');
	const viewBtn = $('mh-view'), viewNote = $('mh-view-note'), viewLabels = app.querySelectorAll('.mh-view-label');
	const themeSel = $('mh-theme'), peekCb = $('mh-peek-cb'), tenCb = $('mh-ten-cb'), spaceHost = $('mh-space');
	const titleEl = app.querySelector('.mh-title'), bulbsEl = app.querySelector('.mh-bulbs');
	const startHtml = () => `<span>Pick a door.  Behind one door is a bag of money.  Behind the other ${N > 3 ? 'nine' : 'two'} are goats. <small>(<a href="https://en.wikipedia.org/wiki/Monty_Hall_problem" target="_blank" rel="noopener">What?!</a>)</small></span>`;
	const STATS_KEY = 'montyHall.stats', THEME_KEY = 'montyHall.theme', VIEW_KEY = 'montyHall.statsView';
	const DEFAULT_THEME = '4';
	const NARROW = window.matchMedia('(max-width: 520px)');
	const wait = ms => new Promise(r => setTimeout(r, ms));
	const isTheme = n => app.classList.contains('mh-theme-' + n);
	const doorMs = () => (parseFloat(getComputedStyle(app).getPropertyValue('--door-ms')) || 0.9) * 1000 + 50;
	// unbiased integer in [0, n) from the browser's CSPRNG (rejection sampling)
	const rand = n => {
		const buf = new Uint32Array(1), lim = Math.floor(0x100000000 / n) * n;
		let x;
		do { crypto.getRandomValues(buf); x = buf[0]; } while (x >= lim);
		return x % n;
	};
	// always start unchecked (browsers like Firefox restore checkbox state on reload)
	peekCb.checked = tenCb.checked = false;
	const range = n => [...Array(n).keys()];
	let N = 3;  // number of doors (3, or 10 when the "10 doors" option is checked)
	let g = { phase: 'init', prize: 0, pick: -1, opened: [], other: -1, cur: -1 };
	// ---- full-width layout (window width minus a side margin) ----
	function fitWidth() {
		const m = NARROW.matches ? 8 : 20;
		app.style.width = (document.documentElement.clientWidth - 2 * m) + 'px';
		app.style.marginLeft = '0px';
		app.style.marginLeft = (m - app.getBoundingClientRect().left) + 'px';
	}
	// ---- confetti (p5 instance, fixed overlay): bursts up from a door, then flutters down ----
	const confetti = (() => {
		let P = null, parts = [], t0 = 0;
		const DURATION = 3400, FADE = 800, G = 0.003;
		const cols = ['#ffd23f', '#e4002b', '#00a651', '#0b74d6', '#ff7ab6', '#ffffff', '#9b5de5', '#ff9f1c'];
		new p5(s => {
			s.setup = () => {
				const c = s.createCanvas(s.windowWidth, s.windowHeight);
				c.elt.setAttribute('aria-hidden', 'true');
				c.style('position', 'fixed'); c.style('top', '0'); c.style('left', '0');
				c.style('pointer-events', 'none'); c.style('z-index', '9999');
				s.rectMode(s.CENTER); s.noStroke(); s.noLoop();
				P = s;
			};
			s.windowResized = () => s.resizeCanvas(s.windowWidth, s.windowHeight);
			s.draw = () => {
				const t = s.millis() - t0;
				s.clear();
				if (t >= DURATION) { parts = []; s.noLoop(); return; }
				const a = t > DURATION - FADE ? 255 * (DURATION - t) / FADE : 255;
				const dt = Math.min(s.deltaTime, 50), f = dt / 16.7, drag = Math.pow(0.996, dt);
				for (const q of parts) {
					if (t < q.delay) continue;
					q.vy = Math.min(q.vy + G * dt, q.vterm);
					q.vx *= drag;
					q.ph += q.dph * dt;
					q.x += q.vx * dt + (q.vy > 0 ? Math.sin(q.ph) * q.sway * f : 0);
					q.y += q.vy * dt;
					q.r += q.dr * dt;
					q.flip += q.dflip * dt;
					q.c.setAlpha(a);
					s.push(); s.translate(q.x, q.y); s.rotate(q.r); s.fill(q.c);
					if (q.round) s.ellipse(0, 0, q.w * 0.8, q.w * 0.8 * Math.abs(Math.cos(q.flip)) + 1);
					else s.rect(0, 0, q.w * Math.abs(Math.cos(q.flip)) + 1, q.h);
					s.pop();
				}
			};
		});
		return {
			burst(rect) {
				if (!P) return;
				const s = P;
				const cx = rect.left + rect.width / 2, cy = rect.top + rect.height * 0.45;
				const rise = Math.max(160, cy);
				const n = Math.round(Math.min(300, 140 + s.width * 0.1));
				parts = [];
				for (let i = 0; i < n; i++) {
					const spread = s.random(-0.6, 0.6), v = Math.sqrt(2 * G * rise * s.random(0.45, 1.05));
					parts.push({
						x: cx + s.random(-rect.width * 0.3, rect.width * 0.3),
						y: cy + s.random(-rect.height * 0.2, rect.height * 0.2),
						vx: Math.sin(spread) * v * s.random(0.8, 1.6), vy: -Math.cos(spread) * v,
						vterm: s.random(0.09, 0.2), delay: s.random(0, 220),
						ph: s.random(s.TWO_PI), dph: s.random(0.004, 0.01), sway: s.random(0.6, 1.8),
						r: s.random(s.TWO_PI), dr: s.random(-0.008, 0.008),
						flip: s.random(s.TWO_PI), dflip: s.random(0.008, 0.02),
						w: s.random(7, 12), h: s.random(10, 16),
						c: s.color(s.random(cols)), round: s.random() < 0.2
					});
				}
				t0 = s.millis();
				s.loop();
			}
		};
	})();
	// ---- theme 4 background: warp star field + rainbow lasers (p5 instance) ----
	// Each star eases radially outward from near the center to the screen edge (in its own
	// direction) over T seconds, visible the whole way: fastest ~8s, slowest ~30s.
	const space = (() => {
		const EASE = 1.6, START = 0.03;
		let S = null, on = false, stars = [], cx = 0, cy = 0;
		function edgeDist(ca, sa) {
			const W = S.width, H = S.height;
			const dx = ca > 1e-6 ? (W - cx) / ca : ca < -1e-6 ? cx / -ca : Infinity;
			const dy = sa > 1e-6 ? (H - cy) / sa : sa < -1e-6 ? cy / -sa : Infinity;
			return Math.min(dx, dy) + 8;
		}
		function newStar(init) {
			const s = S, T = 8 + Math.pow(s.random(), 1.5) * 22, a = s.random(s.TWO_PI);
			const ca = Math.cos(a), sa = Math.sin(a);
			return { ca, sa, R: edgeDist(ca, sa), u: init ? s.random() : 0, du: 1 / (T * 1000), sf: 8 / T };
		}
		const radius = (st, u) => st.R * (START + (1 - START) * Math.pow(Math.max(0, u), EASE));
		function seed() {
			cx = S.width / 2; cy = S.height * 0.4;
			const n = Math.min(260, Math.round(S.width * S.height / 4500));
			stars = [];
			for (let i = 0; i < n; i++) stars.push(newStar(true));
		}
		function fit() {
			if (!S) return;
			const w = Math.max(1, spaceHost.clientWidth), h = Math.max(1, spaceHost.clientHeight);
			if (w !== S.width || h !== S.height) { S.resizeCanvas(w, h); seed(); }
		}
		new p5(s => {
			s.setup = () => {
				const c = s.createCanvas(Math.max(1, spaceHost.clientWidth), Math.max(1, spaceHost.clientHeight));
				c.parent(spaceHost);
				s.colorMode(s.HSB, 360, 100, 100, 1);
				s.noLoop();
				S = s;
				seed();
				if (on) { fit(); s.loop(); }
			};
			s.draw = () => {
				const dt = Math.min(s.deltaTime, 50), t = s.millis(), W = s.width, H = s.height;
				s.background(0);
				for (const st of stars) {
					st.u += st.du * dt;
					if (st.u >= 1) { Object.assign(st, newStar(false)); continue; }
					const r = radius(st, st.u), pr = radius(st, st.u - st.du * Math.max(dt, 16) * 4);
					s.stroke(0, 0, 100, Math.min(1, 0.3 + st.u * 0.9) * (0.4 + 0.6 * st.sf));
					s.strokeWeight(0.6 + st.u * 2.2 * (0.5 + 0.5 * st.sf));
					s.line(cx + st.ca * pr, cy + st.sa * pr, cx + st.ca * r, cy + st.sa * r);
				}
				s.blendMode(s.ADD);
				const L = Math.hypot(W, H);
				for (let i = 0; i < 4; i++) {
					const ox = W * (0.12 + 0.25 * i), oy = H + 10;
					const ang = -Math.PI / 2 + Math.sin(t * 0.00035 + i * 1.7) * 0.55;
					const ex = ox + Math.cos(ang) * L, ey = oy + Math.sin(ang) * L;
					const hue = (t * 0.03 + i * 90) % 360;
					s.stroke(hue, 90, 100, 0.07); s.strokeWeight(14); s.line(ox, oy, ex, ey);
					s.stroke(hue, 80, 100, 0.16); s.strokeWeight(5); s.line(ox, oy, ex, ey);
					s.stroke(hue, 40, 100, 0.45); s.strokeWeight(1.5); s.line(ox, oy, ex, ey);
				}
				s.blendMode(s.BLEND);
			};
		});
		return {
			start() { on = true; if (S) { fit(); S.loop(); } },
			stop() { on = false; if (S) S.noLoop(); },
			fit
		};
	})();
	// ---- doors ----
	let slots = [];
	function buildDoors() {
		doorsEl.innerHTML = '';
		doorsEl.classList.toggle('mh-many', N > 3);
		slots = range(N).map(i => {
			const slot = document.createElement('div');
			slot.className = 'mh-slot';
			slot.innerHTML = `<div class="mh-peek"></div><button class="mh-door" type="button" aria-label="Door ${i + 1}"><span class="mh-behind"></span><span class="mh-panel"><span class="mh-num">${i + 1}</span><span class="mh-knob"></span></span></button><div class="mh-tag"></div>`;
			const door = slot.querySelector('.mh-door');
			door.addEventListener('click', () => pick(i));
			doorsEl.appendChild(slot);
			return { slot, door, behind: slot.querySelector('.mh-behind'), tag: slot.querySelector('.mh-tag'), peek: slot.querySelector('.mh-peek') };
		});
	}
	buildDoors();
	// ---- spotlight: fixed source above, beam pivots to point at a door ----
	// The beam runs 2.4x the distance to the door and fades out along its length (see .mh-beam CSS).
	const BEAM_LEN = 2.4, BEAM_AT_DOOR = 1 / BEAM_LEN;
	const pool = document.createElement('div');
	const beam = document.createElement('div');
	pool.className = 'mh-light mh-pool';
	beam.className = 'mh-light mh-beam';
	pool.setAttribute('aria-hidden', 'true');
	beam.setAttribute('aria-hidden', 'true');
	app.appendChild(pool);
	app.appendChild(beam);
	let lightIdx = 1, aim = null, lightRaf = 0, lightAnim = false, wanderTimer = 0;
	function doorPt(i) {
		const a = app.getBoundingClientRect(), d = slots[i].door.getBoundingClientRect();
		return { x: d.left - a.left + d.width / 2, y: d.top - a.top + d.height / 2, w: d.width, h: d.height };
	}
	function renderLight(p) {
		const sx = app.clientWidth / 2, sy = -40, dx = p.x - sx, dy = p.y - sy;
		const dist = Math.hypot(dx, dy), len = dist * BEAM_LEN, ang = Math.atan2(dx, dy);
		// cone spans 20% of its width at the top and 100% at the bottom; size it to ~1.4 door widths at the door
		const bw = (p.w * 1.4) / (0.2 + 0.8 * BEAM_AT_DOOR);
		beam.style.width = bw + 'px';
		beam.style.height = len + 'px';
		beam.style.transform = `translate(${sx - bw / 2}px,${sy}px) rotate(${-ang}rad)`;
		const pw = p.w * 1.8, ph = p.h * 1.2;
		pool.style.width = pw + 'px';
		pool.style.height = ph + 'px';
		pool.style.transform = `translate(${p.x - pw / 2}px,${p.y - ph / 2}px)`;
		if (!beam.classList.contains('mh-on')) { beam.classList.add('mh-on'); pool.classList.add('mh-on'); }
	}
	function aimAt(i, ms) {
		cancelAnimationFrame(lightRaf);
		lightIdx = i;
		if (!ms || !aim) { aim = doorPt(i); renderLight(aim); lightAnim = false; return; }
		const from = aim, t0 = performance.now();
		lightAnim = true;
		const tick = now => {
			const k = Math.min(1, (now - t0) / ms);
			const e = k < 0.5 ? 2 * k * k : 1 - Math.pow(-2 * k + 2, 2) / 2;
			const to = doorPt(i);
			aim = { x: from.x + (to.x - from.x) * e, y: from.y + (to.y - from.y) * e, w: from.w + (to.w - from.w) * e, h: from.h + (to.h - from.h) * e };
			renderLight(aim);
			if (k < 1) lightRaf = requestAnimationFrame(tick); else lightAnim = false;
		};
		lightRaf = requestAnimationFrame(tick);
	}
	function updateLight() {
		clearTimeout(wanderTimer);
		if (g.cur >= 0) { aimAt(g.cur, 650); return; }
		if (!aim) aimAt(lightIdx, 0);
		// sweep back and forth across the doors: 0,1,2,1 for 3 doors; 0..9,8..1 for 10
		const seq = range(N).concat(range(N).slice(1, -1).reverse()), many = N > 3;
		let k = Math.max(0, seq.indexOf(lightIdx));
		const step = () => {
			k = (k + 1) % seq.length;
			aimAt(seq[k], many ? 900 : 1500);
			wanderTimer = setTimeout(step, many ? 1500 : 2600);
		};
		wanderTimer = setTimeout(step, 900);
	}
	function refreshLight() {
		if (!lightAnim) { aim = doorPt(lightIdx); renderLight(aim); }
	}
	// ---- theme 3 marquee bulbs ----
	function layoutBulbs() {
		if (!isTheme(3)) { if (bulbsEl.childElementCount) bulbsEl.innerHTML = ''; return; }
		const w = bulbsEl.clientWidth, h = bulbsEl.clientHeight;
		if (!w || !h) return;
		const per = 2 * (w + h), n = Math.max(12, Math.round(per / 22 / 3) * 3), step = per / n;
		let html = '';
		for (let i = 0; i < n; i++) {
			let d = i * step, x, y;
			if (d < w) { x = d; y = 0; }
			else if ((d -= w) < h) { x = w; y = d; }
			else if ((d -= h) < w) { x = w - d; y = h; }
			else { d -= w; x = 0; y = h - d; }
			const delay = (-((3 - i % 3) % 3) * 0.2).toFixed(1);
			html += `<i style="left:${x.toFixed(1)}px;top:${y.toFixed(1)}px;animation-delay:${delay}s"></i>`;
		}
		bulbsEl.innerHTML = html;
	}
	// ---- door helpers ----
	function setPicked(i) {
		g.cur = i;
		slots.forEach((s, j) => {
			s.door.classList.toggle('mh-picked', j === i);
			s.tag.textContent = j === i ? (N > 3 ? 'Pick' : 'Your pick') : '';
		});
		updateLight();
	}
	function updatePeek() {
		const show = peekCb.checked && g.pick >= 0;
		slots.forEach((s, i) => {
			const cash = i === g.prize;
			s.peek.textContent = show ? (cash ? 'Cash' : 'Goat') : '';
			s.peek.classList.toggle('mh-peek-cash', show && cash);
		});
	}
	function openDoor(i) {
		const s = slots[i], cash = i === g.prize;
		s.behind.textContent = cash ? '💰' : '🐐';
		s.slot.classList.toggle('mh-cash', cash);
		s.door.classList.add('mh-open');
		s.door.setAttribute('aria-label', `Door ${i + 1}: ${cash ? 'money' : 'goat'}`);
	}
	// ---- game flow ----
	async function newGame() {
		const my = g = { phase: 'busy', prize: rand(N), pick: -1, opened: [], other: -1, cur: -1 };
		app.classList.remove('mh-picking');
		againBtn.hidden = true;
		[keepBtn, switchBtn].forEach(b => { b.hidden = true; b.disabled = false; b.classList.remove('mh-chosen'); });
		msg.innerHTML = startHtml();
		msg.classList.remove('mh-result', 'mh-lose');
		setPicked(-1);
		updatePeek();
		const anyOpen = slots.some(s => s.door.classList.contains('mh-open'));
		slots.forEach(s => s.door.classList.remove('mh-open'));
		if (anyOpen) await wait(doorMs());
		if (g !== my) return;  // a newer game started while waiting
		slots.forEach((s, i) => {
			s.behind.textContent = '';
			s.slot.classList.remove('mh-cash');
			s.door.setAttribute('aria-label', `Door ${i + 1}`);
		});
		g.phase = 'pick';
		app.classList.add('mh-picking');
	}
	async function pick(i) {
		if (g.phase !== 'pick') return;
		const my = g;
		g.phase = 'busy';
		g.pick = i;
		app.classList.remove('mh-picking');
		setPicked(i);
		updatePeek();
		msg.textContent = `You picked door ${i + 1}. Monty is opening ${N > 3 ? 'the other doors' : 'another door'}…`;
		// leave one other door closed: the cash door, or a random door if the player picked the cash
		const others = range(N).filter(d => d !== i);
		g.other = i === g.prize ? others[rand(others.length)] : g.prize;
		g.opened = others.filter(d => d !== g.other);
		await wait(500);
		if (g !== my) return;
		g.opened.forEach(d => openDoor(d));
		await wait(doorMs());
		if (g !== my) return;
		const reveal = N > 3 ? `Monty opened ${g.opened.length} doors: all goats!` : `Door ${g.opened[0] + 1} has a goat!`;
		msg.textContent = `${reveal} Keep door ${i + 1}, or switch to door ${g.other + 1}?`;
		keepBtn.hidden = switchBtn.hidden = false;
		g.phase = 'decide';
	}
	async function decide(sw) {
		if (g.phase !== 'decide') return;
		const my = g;
		g.phase = 'busy';
		(sw ? switchBtn : keepBtn).classList.add('mh-chosen');
		keepBtn.disabled = switchBtn.disabled = true;
		const final = sw ? g.other : g.pick;
		setPicked(final);
		msg.textContent = sw ? `Switched to door ${final + 1}…` : `Sticking with door ${final + 1}…`;
		await wait(500);
		if (g !== my) return;
		[g.pick, g.other].forEach(d => openDoor(d));
		await wait(doorMs() + 150);
		if (g !== my) return;
		const win = final === g.prize;
		if (N === 3) record(sw ? 'switched' : 'kept', win);
		msg.textContent = win ? 'You win!' : 'Try Again!';
		msg.classList.add('mh-result');
		msg.classList.toggle('mh-lose', !win);
		if (win) confetti.burst(slots[g.prize].door.getBoundingClientRect());
		keepBtn.hidden = switchBtn.hidden = true;
		againBtn.hidden = false;
		againBtn.focus({ preventScroll: true });
		g.phase = 'done';
	}
	keepBtn.addEventListener('click', () => decide(false));
	switchBtn.addEventListener('click', () => decide(true));
	againBtn.addEventListener('click', newGame);
	peekCb.addEventListener('change', updatePeek);
	tenCb.addEventListener('change', () => {
		N = tenCb.checked ? 10 : 3;
		cancelAnimationFrame(lightRaf);
		lightAnim = false;
		if (lightIdx >= N) lightIdx = 0;
		buildDoors();
		refreshLight();
		updateNote();
		newGame();
		// keep "?doors=10" in the URL in sync with the checkbox (no reload, no new history entry)
		try {
			const u = new URL(location.href);
			if (tenCb.checked) u.searchParams.set('doors', '10'); else u.searchParams.delete('doors');
			history.replaceState(history.state, '', u);
		} catch (e) {}
	});
	// ---- stats: all-time (localStorage) and this visit (memory only; resets on reload) ----
	const blank = () => ({ kept: { cash: 0, goat: 0 }, switched: { cash: 0, goat: 0 } });
	function loadStats() {
		try {
			const s = JSON.parse(localStorage.getItem(STATS_KEY));
			if (s && s.kept && s.switched) return s;
		} catch (e) {}
		return blank();
	}
	let allStats = loadStats(), visitStats = blank(), view = 'visit';
	function saveStats() { try { localStorage.setItem(STATS_KEY, JSON.stringify(allStats)); } catch (e) {} }
	function record(key, win) {
		const field = win ? 'cash' : 'goat';
		allStats[key][field]++;
		visitStats[key][field]++;
		saveStats();
		renderStats();
	}
	const games = n => `${n} game${n === 1 ? '' : 's'}`;
	const pct = (n, t) => t ? (100 * n / t).toFixed(2) + '%' : '—';
	function renderStats() {
		const stats = view === 'all' ? allStats : visitStats;
		const block = (title, s) => {
			const t = s.cash + s.goat;
			return `<div class="mh-stat"><h3>${title}</h3><p>Cash found: ${games(s.cash)} (${pct(s.cash, t)})</p><p>Goat found: ${games(s.goat)} (${pct(s.goat, t)})</p></div>`;
		};
		statsEl.innerHTML = block('Initial Choice Kept', stats.kept) + block('Switched Door', stats.switched);
	}
	function setView(v) {
		view = v === 'all' ? 'all' : 'visit';
		viewBtn.setAttribute('aria-checked', String(view === 'all'));
		viewLabels.forEach(l => l.classList.toggle('mh-active', l.dataset.v === view));
		updateNote();
		try { localStorage.setItem(VIEW_KEY, view); } catch (e) {}
		renderStats();
	}
	const statsWrap = app.querySelector('.mh-stats-wrap');
	function updateNote() {
		viewNote.textContent = N > 3 ? 'Stats aren’t kept for 10-door games.' : 'Just for this browser.';
		viewNote.classList.toggle('mh-show', N > 3 || view === 'all');
		statsWrap.classList.toggle('mh-untracked', N > 3);
	}
	viewBtn.addEventListener('click', () => setView(view === 'all' ? 'visit' : 'all'));
	viewLabels.forEach(l => l.addEventListener('click', () => setView(l.dataset.v)));
	function resetStats() { allStats = blank(); visitStats = blank(); saveStats(); renderStats(); }
	resetBtn.addEventListener('click', () => {
		if (typeof dlg.showModal === 'function') { dlg.returnValue = ''; dlg.showModal(); }
		else if (confirm('Are You Sure?')) resetStats();
	});
	dlg.addEventListener('close', () => { if (dlg.returnValue === 'reset') resetStats(); });
	// ---- theme ----
	function setTheme(n) {
		app.classList.remove('mh-theme-1', 'mh-theme-2', 'mh-theme-3', 'mh-theme-4');
		app.classList.add('mh-theme-' + n);
		themeSel.value = n;
		try { localStorage.setItem(THEME_KEY, n); } catch (e) {}
		if (n === '4') space.start(); else space.stop();
		layoutBulbs();
		refreshLight();
	}
	themeSel.addEventListener('change', () => setTheme(themeSel.value));
	// ---- "Options" link toggles the hidden options ----
	const optsBtn = $('mh-opts');
	optsBtn.addEventListener('click', () => {
		const shown = app.classList.toggle('mh-show-opts');
		optsBtn.setAttribute('aria-expanded', String(shown));
	});
	// ---- sizing ----
	window.addEventListener('resize', fitWidth);
	window.addEventListener('load', () => { fitWidth(); refreshLight(); });
	new ResizeObserver(() => layoutBulbs()).observe(titleEl);
	new ResizeObserver(() => { space.fit(); refreshLight(); }).observe(app);
	// ---- init ----
	// "?doors=10" in the URL starts in 10-door mode with the options shown
	if (new URLSearchParams(location.search).get('doors') === '10') {
		tenCb.checked = true;
		N = 10;
		buildDoors();
		app.classList.add('mh-show-opts');
		optsBtn.setAttribute('aria-expanded', 'true');
	}
	fitWidth();
	let savedTheme = null, savedView = null;
	try { savedTheme = localStorage.getItem(THEME_KEY); savedView = localStorage.getItem(VIEW_KEY); } catch (e) {}
	setTheme(['1', '2', '3', '4'].includes(savedTheme) ? savedTheme : DEFAULT_THEME);
	setView(savedView);
	newGame();
})();
</script>
