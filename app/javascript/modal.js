// ========================================
// モーダル関連の共通処理
// ========================================

// モーダル閉じるボタンをクリックしたとき
document.addEventListener("click", (e) => {
  if (e.target.matches("#modal .modal-close")) {
    e.preventDefault();
    const modal = document.getElementById("modal");
    if (modal) modal.innerHTML = ""; // モーダルを閉じる
  }
});

// 各recordモデルの行全体クリックでeditへ
document.addEventListener("turbo:load", () => {
  document.addEventListener("click", (e) => {
    const row = e.target.closest(".clickable-row");
    if (!row) return;

    const href = row.dataset.href;
    const turboFrame = row.dataset.turboFrame || "modal";
    Turbo.visit(href, { frame: turboFrame });
  });
});

// アカウント設定のアカウント削除ボタンの警告モーダル
document.addEventListener("turbo:load", () => {
  const modal = document.getElementById("deleteAccountModal");
  const openBtn = document.getElementById("deleteAccountBtn");
  const cancelBtn = document.getElementById("cancelDeleteBtn");

  if (!modal || !openBtn || !cancelBtn) return;

  openBtn.addEventListener("click", () => {
    modal.classList.remove("hidden");
  });

  cancelBtn.addEventListener("click", () => {
    modal.classList.add("hidden");
  });

  // モーダル外クリックで閉じる場合
  modal.addEventListener("click", (e) => {
    if (e.target === modal) modal.classList.add("hidden");
  });
});