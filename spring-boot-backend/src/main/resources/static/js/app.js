document.addEventListener('DOMContentLoaded', function() {
    // Mobile nav toggle
    const toggle = document.querySelector('.navbar-toggle');
    const links = document.querySelector('.navbar-links');
    if (toggle && links) {
        toggle.addEventListener('click', function() {
            links.classList.toggle('open');
        });
        document.addEventListener('click', function(e) {
            if (!toggle.contains(e.target) && !links.contains(e.target)) {
                links.classList.remove('open');
            }
        });
    }

    // Tab switching
    document.querySelectorAll('.tab-btn').forEach(function(btn) {
        btn.addEventListener('click', function() {
            var group = this.closest('.tabs');
            group.querySelectorAll('.tab-btn').forEach(function(b) { b.classList.remove('active'); });
            this.classList.add('active');
            var target = this.dataset.target;
            if (target) {
                document.querySelectorAll('.tab-panel').forEach(function(p) { p.style.display = 'none'; });
                document.getElementById(target).style.display = 'block';
            }
        });
    });

    // Form loading state
    document.querySelectorAll('form[data-loading]').forEach(function(form) {
        form.addEventListener('submit', function() {
            var btn = this.querySelector('button[type="submit"]');
            if (btn) {
                btn.classList.add('loading');
                btn.disabled = true;
            }
        });
    });
});

function shareOnWhatsApp(name, age, camp, status) {
    var text = 'Help find ' + name + ' (Age: ' + age + ')\n';
    if (camp) text += 'Camp: ' + camp + '\n';
    if (status) text += 'Status: ' + status + '\n';
    text += '\nSearch on Aasha: ' + window.location.origin + '/search';
    var url = 'https://wa.me/?text=' + encodeURIComponent(text);
    window.open(url, '_blank');
}

function shareCampOnWhatsApp(campName, contact) {
    var text = 'Aasha Disaster Relief Camp\n\n';
    text += 'Camp: ' + campName + '\n';
    if (contact) text += 'Contact: ' + contact + '\n';
    text += '\nFind more at: ' + window.location.origin + '/camps';
    var url = 'https://wa.me/?text=' + encodeURIComponent(text);
    window.open(url, '_blank');
}
