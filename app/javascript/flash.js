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

function initFlash() {
  // ページ内の全ての flash に対して処理
  document.querySelectorAll(".flash").forEach(setupFlash);

  // Turbo Streamで新しく追加されたflashも処理
  const flashContainer = document.getElementById("flash-messages");
  if (flashContainer) {
    const observer = new MutationObserver(() => {
      flashContainer.querySelectorAll(".flash").forEach(setupFlash);
    });
    observer.observe(flashContainer, { childList: true, subtree: true });
  }
}

// Turboでページがロードされるたびに初期化
document.addEventListener("turbo:load", initFlash);