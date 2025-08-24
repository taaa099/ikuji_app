function showNotification(title, message) {
  const popup = document.getElementById("notification-popup");
  if (!popup) return; // 念のため要素が存在するか確認
  document.getElementById("notification-title").innerText = title;
  document.getElementById("notification-message").innerText = message;

  popup.classList.add("show");

  setTimeout(() => {
    popup.classList.remove("show");
  }, 5000);
}

// ページ読み込み時にテスト通知を出す
document.addEventListener("DOMContentLoaded", () => {
  showNotification("テスト通知", "通知の内容がここに入ります！");
});

export { showNotification };