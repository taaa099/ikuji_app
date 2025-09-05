function showNotification(title, message, notification_kind) {
  const container = document.getElementById("notification-container")
  if (!container) return

  const popup = document.createElement("div")
  popup.className = "notification-popup"

  // notification_kind に応じて色を変える
  if (notification_kind === "alert") {
    popup.style.backgroundColor = "#ffcccc" // 赤系
  } else if (notification_kind === "reminder") {
    popup.style.backgroundColor = "#ccffcc" // 緑系
  }

  const titleEl = document.createElement("div")
  titleEl.className = "notification-title"
  titleEl.innerText = title

  const messageEl = document.createElement("div")
  messageEl.className = "notification-message"
  messageEl.innerText = message

  popup.appendChild(titleEl)
  popup.appendChild(messageEl)
  container.appendChild(popup)

  void popup.offsetWidth
  popup.classList.add("show")

  // 5秒後に非表示にする
  setTimeout(() => {
    popup.addEventListener("transitionend", () => popup.remove(), { once: true })
    popup.classList.remove("show")
  }, 5000)
}

export { showNotification }