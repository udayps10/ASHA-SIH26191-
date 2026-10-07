/* ============================================================
   AASHA Core JavaScript
   ============================================================ */

document.addEventListener('DOMContentLoaded', function() {
  initNavbar();
  initSidebar();
  initForms();
  initToasts();
  initModals();
  initChips();
});

/* ---- MOBILE NAV ---- */
function toggleMobileNav() {
  var nav = document.getElementById('mobileNav');
  if (nav) nav.classList.toggle('open');
  document.body.style.overflow = nav && nav.classList.contains('open') ? 'hidden' : '';
}

function closeMobileNav(e) {
  if (e && e.target && e.target.id === 'mobileNav') toggleMobileNav();
}

/* ---- NAVBAR ---- */
function initNavbar() {
  var toggle = document.querySelector('.a-navbar-toggle');
  var nav = document.querySelector('.a-navbar-nav');
  if (!toggle || !nav) return;

  toggle.addEventListener('click', function(e) {
    e.stopPropagation();
    nav.classList.toggle('open');
    toggle.setAttribute('aria-expanded', nav.classList.contains('open'));
  });

  document.addEventListener('click', function(e) {
    if (!toggle.contains(e.target) && !nav.contains(e.target)) {
      nav.classList.remove('open');
      toggle.setAttribute('aria-expanded', 'false');
    }
  });
}

/* ---- SIDEBAR ---- */
function initSidebar() {
  var sidebarToggle = document.querySelector('.a-sidebar-toggle');
  var sidebar = document.querySelector('.a-sidebar');
  var overlay = document.querySelector('.a-sidebar-overlay');
  var main = document.querySelector('.a-main');

  if (sidebarToggle && sidebar) {
    sidebarToggle.addEventListener('click', function() {
      sidebar.classList.toggle('open');
      if (overlay) overlay.classList.toggle('active');
    });
  }

  if (overlay) {
    overlay.addEventListener('click', function() {
      sidebar.classList.remove('open');
      overlay.classList.remove('active');
    });
  }

  if (main) {
    main.addEventListener('click', function() {
      if (sidebar && sidebar.classList.contains('open')) {
        sidebar.classList.remove('open');
        if (overlay) overlay.classList.remove('active');
      }
    });
  }
}

/* ---- FORMS ---- */
function initForms() {
  document.querySelectorAll('form[data-loading]').forEach(function(form) {
    form.addEventListener('submit', function() {
      var btn = this.querySelector('button[type="submit"]');
      if (btn && !btn.disabled) {
        btn.classList.add('loading');
        btn.disabled = true;
      }
    });
  });
}

/* ---- TOASTS ---- */
function initToasts() {
  if (!document.querySelector('.toast-container')) {
    var container = document.createElement('div');
    container.className = 'toast-container';
    container.setAttribute('aria-live', 'polite');
    container.setAttribute('aria-atomic', 'true');
    document.body.appendChild(container);
  }
}

function showToast(message, type) {
  type = type || 'info';
  var container = document.querySelector('.toast-container');
  if (!container) return;

  var icons = {
    success: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>',
    error: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>',
    warning: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m21.73 18-8-14a2 2 0 0 0-3.48 0l-8 14A2 2 0 0 0 4 21h16a2 2 0 0 0 1.73-3Z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/></svg>',
    info: '<svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>'
  };

  var toast = document.createElement('div');
  toast.className = 'toast toast-' + type;
  toast.innerHTML = (icons[type] || '') + '<span>' + message + '</span>';
  container.appendChild(toast);

  setTimeout(function() {
    toast.style.opacity = '0';
    toast.style.transform = 'translateX(100%)';
    toast.style.transition = 'all 0.3s ease';
    setTimeout(function() { toast.remove(); }, 300);
  }, 4000);
}

/* ---- MODALS ---- */
function initModals() {
  document.querySelectorAll('[data-modal]').forEach(function(trigger) {
    trigger.addEventListener('click', function(e) {
      e.preventDefault();
      var target = document.getElementById(this.dataset.modal);
      if (target) openModal(target);
    });
  });

  document.querySelectorAll('.modal-close').forEach(function(btn) {
    btn.addEventListener('click', function() {
      var modal = this.closest('.modal-backdrop');
      if (modal) closeModal(modal);
    });
  });

  document.querySelectorAll('.modal-backdrop').forEach(function(backdrop) {
    backdrop.addEventListener('click', function(e) {
      if (e.target === this) closeModal(this);
    });
  });
}

function openModal(modal) {
  modal.style.display = 'flex';
  document.body.style.overflow = 'hidden';
  var firstInput = modal.querySelector('input, textarea, select, button:not(.modal-close)');
  if (firstInput) firstInput.focus();
}

function closeModal(modal) {
  modal.style.display = 'none';
  document.body.style.overflow = '';
}

/* ---- CHIP FILTERS ---- */
function initChips() {
  document.querySelectorAll('.chip-group').forEach(function(group) {
    group.querySelectorAll('.chip').forEach(function(chip) {
      chip.addEventListener('click', function() {
        group.querySelectorAll('.chip').forEach(function(c) { c.classList.remove('active'); });
        this.classList.add('active');
        var filter = this.dataset.filter;
        if (filter) filterRecords(filter);
      });
    });
  });
}

function filterRecords(filter) {
  document.querySelectorAll('[data-record-type]').forEach(function(item) {
    if (filter === 'all' || item.dataset.recordType === filter) {
      item.style.display = '';
    } else {
      item.style.display = 'none';
    }
  });
}

/* ---- WHATSAPP SHARING ---- */
function shareOnWhatsApp(name, age, camp, status) {
  var text = 'Help find ' + name + ' (Age: ' + age + ')\n';
  if (camp) text += 'Camp: ' + camp + '\n';
  if (status) text += 'Status: ' + status + '\n';
  text += '\nSearch on Aasha: ' + window.location.origin + '/search';
  window.open('https://wa.me/?text=' + encodeURIComponent(text), '_blank');
}

function shareCampOnWhatsApp(campName, contact) {
  var text = 'Aasha Disaster Relief Camp\n\n';
  text += 'Camp: ' + campName + '\n';
  if (contact) text += 'Contact: ' + contact + '\n';
  text += '\nFind more at: ' + window.location.origin + '/camps';
  window.open('https://wa.me/?text=' + encodeURIComponent(text), '_blank');
}

/* ---- CONFIRMATION DIALOG ---- */
function confirmAction(message, onConfirm) {
  var backdrop = document.createElement('div');
  backdrop.className = 'modal-backdrop';
  backdrop.innerHTML = '<div class="modal" style="max-width:400px"><div class="modal-body" style="text-align:center;padding:32px"><p style="margin-bottom:24px;font-size:15px">' + message + '</p><div style="display:flex;gap:12px;justify-content:center"><button class="btn btn-ghost modal-close">Cancel</button><button class="btn btn-danger" id="confirm-action-btn">Confirm</button></div></div></div>';
  document.body.appendChild(backdrop);
  backdrop.style.display = 'flex';
  document.body.style.overflow = 'hidden';

  backdrop.querySelector('.modal-close').addEventListener('click', function() {
    backdrop.remove();
    document.body.style.overflow = '';
  });
  backdrop.addEventListener('click', function(e) {
    if (e.target === this) {
      backdrop.remove();
      document.body.style.overflow = '';
    }
  });
  backdrop.querySelector('#confirm-action-btn').addEventListener('click', function() {
    backdrop.remove();
    document.body.style.overflow = '';
    if (onConfirm) onConfirm();
  });
}

/* ---- GEOLOCATION ---- */
function getCurrentLocation(callback) {
  if (!navigator.geolocation) {
    showToast('Geolocation is not supported by your browser', 'error');
    return;
  }
  navigator.geolocation.getCurrentPosition(
    function(pos) {
      callback({
        lat: pos.coords.latitude,
        lng: pos.coords.longitude,
        accuracy: pos.coords.accuracy
      });
    },
    function(err) {
      var msg = 'Unable to get location';
      if (err.code === 1) msg = 'Location access denied. Please enable location permissions.';
      else if (err.code === 2) msg = 'Location unavailable. Please try again.';
      else if (err.code === 3) msg = 'Location request timed out. Please try again.';
      showToast(msg, 'error');
    },
    { enableHighAccuracy: true, timeout: 15000, maximumAge: 60000 }
  );
}
