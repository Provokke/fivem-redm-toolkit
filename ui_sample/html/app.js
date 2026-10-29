const panel = document.getElementById('panel');

// FiveM sets GetParentResourceName(); fall back so the page also opens in a plain browser.
const resource = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'frt_ui_sample';

function post(name) {
  return fetch(`https://${resource}/${name}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: '{}',
  }).catch(() => {});
}

window.addEventListener('message', (event) => {
  if (event.data.action === 'open') panel.classList.remove('hidden');
  if (event.data.action === 'close') panel.classList.add('hidden');
});

document.getElementById('hello').addEventListener('click', () => post('hello'));
document.getElementById('close').addEventListener('click', () => post('close'));
document.addEventListener('keydown', (e) => { if (e.key === 'Escape') post('close'); });
