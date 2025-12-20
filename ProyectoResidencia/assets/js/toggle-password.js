document.addEventListener('DOMContentLoaded', function () {
  const buttons = document.querySelectorAll('.toggle-password');

  buttons.forEach(function (btn) {
    const wrapper = btn.closest('.input-icon');
    if (!wrapper) return;
    const input = wrapper.querySelector('input');
    if (!input) return;

    // Inicializar estado acorde al tipo del input
    const isText = input.type === 'text';
    btn.setAttribute('aria-pressed', String(isText));
    btn.setAttribute('aria-label', isText ? 'Ocultar contraseña' : 'Mostrar contraseña');

    btn.addEventListener('click', function () {
      const revealed = btn.getAttribute('aria-pressed') === 'true';
      if (revealed) {
        input.setAttribute('type', 'password');
        btn.setAttribute('aria-pressed', 'false');
        btn.setAttribute('aria-label', 'Mostrar contraseña');
      } else {
        input.setAttribute('type', 'text');
        btn.setAttribute('aria-pressed', 'true');
        btn.setAttribute('aria-label', 'Ocultar contraseña');
      }
    });
  });
});

