function showNotification(title, message) {
  const popup = document.getElementById("notification-popup");
  const titleEl = document.getElementById("notification-title");
  const messageEl = document.getElementById("notification-message");
  if (!popup || !titleEl || !messageEl) return;

  titleEl.innerText = title;
  messageEl.innerText = message;

  popup.classList.add("show");

  setTimeout(() => {
    popup.classList.remove("show");
  }, 5000);
}

export { showNotification };