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
