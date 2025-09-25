function setupFlash(flash) {
  if (flash.dataset.processed) return;
  flash.dataset.processed = "true";

  // 3秒後に自動削除
  flash._timeoutId = setTimeout(() => flash.remove(), 3000);

  // ❌ボタン
  const closeBtn = flash.querySelector(".flash-close");
  if (closeBtn) {
    closeBtn.addEventListener("click", () => {
      clearTimeout(flash._timeoutId);
      flash.remove();
    });
  }
}

// 初回フラッシュ
document.querySelectorAll(".flash").forEach(setupFlash);

// Turbo Stream対応
const flashContainer = document.getElementById("flash-messages");
if (flashContainer) {
  const observer = new MutationObserver(() => {
    flashContainer.querySelectorAll(".flash").forEach(setupFlash);
  });
  observer.observe(flashContainer, { childList: true, subtree: true });
}