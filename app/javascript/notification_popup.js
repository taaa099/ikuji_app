function showNotification(title, message, notification_kind) {
  const container = document.getElementById("notification-container")
  if (!container) return

  const popup = document.createElement("div")
  popup.className = `notification-popup ${notification_kind}` // 種別クラスを付与

  // タイトル
  const titleEl = document.createElement("div")
  titleEl.className = "notification-title"
  titleEl.innerText = title

  // メッセージ
  const messageEl = document.createElement("div")
  messageEl.className = "notification-message"
  messageEl.innerText = message

  popup.appendChild(titleEl)
  popup.appendChild(messageEl)
  container.appendChild(popup)

  // 表示アニメーション
  void popup.offsetWidth
  popup.classList.add("show")

  // 5秒後に非表示
  setTimeout(() => {
    popup.addEventListener("transitionend", () => popup.remove(), { once: true })
    popup.classList.remove("show")
  }, 5000)
}

export { showNotification }