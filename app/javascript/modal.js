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