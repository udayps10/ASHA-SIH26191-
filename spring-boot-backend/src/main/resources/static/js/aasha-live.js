(function () {
  var css = document.createElement('style');
  css.textContent = [
    '#aashaAlertBar{display:flex;align-items:stretch;width:100%;min-height:40px;font-size:13.5px;color:#fff;z-index:60;overflow:hidden;box-shadow:0 2px 10px #0000001f}',
    '#aashaAlertBar .liveTag{flex:none;display:flex;align-items:center;gap:8px;padding:0 16px;background:#7f1d1d;font-size:11px;font-weight:800;letter-spacing:1.2px;text-transform:uppercase;white-space:nowrap;z-index:2}',
    '#aashaAlertBar .liveDot{width:8px;height:8px;border-radius:50%;background:#fff;animation:aashaPulse 1.1s ease-in-out infinite}',
    '@keyframes aashaPulse{0%,100%{opacity:1;box-shadow:0 0 0 0 #ffffff88}50%{opacity:.45;box-shadow:0 0 0 6px #ffffff00}}',
    '#aashaAlertBar .ticker{flex:1;overflow:hidden;display:flex;align-items:center;min-width:0}',
    '#aashaAlertBar .tickerTrack{display:inline-flex;white-space:nowrap;will-change:transform;animation-name:aashaTicker;animation-timing-function:linear;animation-iteration-count:infinite}',
    '#aashaAlertBar .tickerTrack span{padding-right:70px}',
    '@keyframes aashaTicker{from{transform:translateX(0)}to{transform:translateX(-50%)}}',
    '#aashaAlertBar .barClose{flex:none;background:transparent;border:none;color:#fff;font-size:19px;line-height:1;padding:0 15px;cursor:pointer;opacity:.85}',
    '#aashaAlertBar .barClose:hover{opacity:1}',
    '#aashaSosBtn{position:fixed;right:22px;bottom:88px;z-index:900;display:inline-flex;align-items:center;gap:9px;background:#dc2626;color:#fff;border:none;border-radius:999px;padding:14px 22px;font-size:15px;font-weight:800;letter-spacing:.4px;cursor:pointer;box-shadow:0 14px 34px #dc262666;transition:transform .15s,background .15s}',
    '#aashaSosBtn:hover{background:#b91c1c;transform:translateY(-2px)}',
    '#aashaSosBtn:disabled{opacity:.7;cursor:wait}',
    '#aashaSosBtn svg{width:18px;height:18px}',
    '#aashaToast{position:fixed;left:50%;bottom:26px;transform:translate(-50%,14px);background:#0b2d47;color:#fff;padding:12px 22px;border-radius:12px;font-size:14px;opacity:0;pointer-events:none;transition:.25s;z-index:999;box-shadow:0 12px 30px #0b2d4740}',
    '#aashaToast.show{opacity:1;transform:translate(-50%,0)}',
    '@media(max-width:650px){#aashaSosBtn{bottom:96px;right:16px;padding:12px 18px;font-size:14px}#aashaAlertBar .liveTag{padding:0 10px;font-size:10px}}'
  ].join('');
  document.head.appendChild(css);

  var toastEl = document.createElement('div');
  toastEl.id = 'aashaToast';
  document.body.appendChild(toastEl);
  var toastTimer;
  function toast(msg) {
    toastEl.textContent = msg;
    toastEl.classList.add('show');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(function () { toastEl.classList.remove('show'); }, 3200);
  }

  function escHtml(s) {
    return String(s == null ? '' : s).replace(/[&<>"]/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c];
    });
  }

  fetch('/api/alerts/active').then(function (r) { return r.ok ? r.json() : []; }).then(function (list) {
    if (!list || !list.length) return;
    var rank = { CRITICAL: 3, WARNING: 2, INFO: 1 };
    var worst = 'INFO';
    list.forEach(function (a) {
      var s = String(a.severity || 'INFO').toUpperCase();
      if ((rank[s] || 1) > (rank[worst] || 1)) worst = s;
    });
    var colors = { CRITICAL: ['#dc2626', '#7f1d1d'], WARNING: ['#f59e0b', '#b45309'], INFO: ['#2563eb', '#1e40af'] };
    var bg = colors[worst] || colors.INFO;
    var text = list.map(function (a) {
      return (a.title || '') + (a.message ? ' — ' + a.message : '');
    }).join('   ●   ');
    if (text.length > 500) text = text.slice(0, 500) + ' …';
    var group = text;
    while (group.length < 320) group += '   ●   ' + text;
    var dur = Math.round(Math.max(20, Math.min(80, group.length / 16)));
    var el = document.createElement('div');
    el.id = 'aashaAlertBar';
    el.style.background = bg[0];
    el.innerHTML =
      '<span class="liveTag" style="background:' + bg[1] + '"><span class="liveDot"></span>Live Alert</span>' +
      '<div class="ticker"><div class="tickerTrack" style="animation-duration:' + dur + 's">' +
      '<span>' + escHtml(group) + '</span><span>' + escHtml(group) + '</span></div></div>' +
      '<button class="barClose" aria-label="Dismiss alert">&times;</button>';
    el.querySelector('.barClose').onclick = function () { el.remove(); };
    var main = document.querySelector('main');
    if (main) main.insertBefore(el, main.firstChild);
  }).catch(function () {});

  var mount = document.getElementById('aashaSosMount');
  if (!mount) return;

  var label = '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round" aria-hidden="true"><path d="M12 9v4"/><path d="M12 17h.01"/><path d="M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0Z"/></svg> Send SOS';
  var btn = document.createElement('button');
  btn.id = 'aashaSosBtn';
  btn.type = 'button';
  btn.innerHTML = label;
  document.body.appendChild(btn);

  btn.onclick = function () {
    if (!navigator.geolocation) { toast('Location unavailable — cannot send SOS.'); return; }
    if (!window.confirm('Send an SOS with your live location to response teams?')) return;
    btn.disabled = true;
    btn.textContent = 'Sending…';
    navigator.geolocation.getCurrentPosition(function (pos) {
      var id = (window.crypto && crypto.randomUUID) ? crypto.randomUUID() : 'sos-' + Date.now() + '-' + Math.floor(Math.random() * 1e6);
      var payload = {
        id: id,
        latitude: pos.coords.latitude,
        longitude: pos.coords.longitude,
        accuracy: pos.coords.accuracy || 10,
        message: 'SOS sent from Aasha website'
      };
      fetch('/api/sos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      }).then(function (r) {
        if (r.status === 401 || r.status === 403) { location.href = '/login'; return null; }
        if (!r.ok) throw new Error('HTTP ' + r.status);
        return r.json();
      }).then(function (data) {
        if (data) toast('SOS sent — response teams notified with your location.');
      }).catch(function (e) { toast('SOS failed: ' + e.message); })
        .finally(function () { btn.disabled = false; btn.innerHTML = label; });
    }, function () {
      toast('Location permission is required to send SOS.');
      btn.disabled = false;
      btn.innerHTML = label;
    }, { enableHighAccuracy: true, timeout: 10000, maximumAge: 30000 });
  };
})();
