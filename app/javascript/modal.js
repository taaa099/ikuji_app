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

// スマホ専用「記録一覧」「＋」モーダル
document.addEventListener("turbo:load", () => {
  const mobileModal = document.getElementById("mobile-modal");
  const mobileModalContent = document.querySelector(".mobile-modal-content");
  const mobileModalTitle = document.getElementById("mobile-modal-title");

  if (!mobileModal || !mobileModalContent || !mobileModalTitle) return;

  const recordItems = mobileModalContent.querySelectorAll(".mobile-modal-item");

  // 開くボタン（記録一覧 / 作成）
  document.querySelectorAll(".open-mobile-modal").forEach(btn => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();

      const mode = btn.dataset.mode;

      // 記録系リンクの href をモードに応じて切り替え
      recordItems.forEach(item => {
        const createHref = item.dataset.createHref;
        const indexHref = item.dataset.indexHref;

        if (mode === "list" && indexHref) {
          item.setAttribute('href', indexHref);
          item.removeAttribute('data-turbo-frame'); // indexは通常遷移
        } else if (mode === "create" && createHref) {
          item.setAttribute('href', createHref);
          item.setAttribute('data-turbo-frame', 'modal'); // newはモーダル表示
        }
      });

      // タイトル切替
      mobileModalTitle.textContent = mode === "list" ? "記録一覧" : "記録作成";

      mobileModal.style.display = "block";
    });
  });

  // モーダル外クリックで閉じる
  mobileModal.addEventListener("click", (e) => {
    if (!mobileModalContent.contains(e.target)) {
      mobileModal.style.display = "none";
    }
  });

  // モーダル内リンククリックで親モーダルを閉じる
  mobileModalContent.querySelectorAll("a").forEach(link => {
    link.addEventListener("click", () => {
      mobileModal.style.display = "none";
      // indexへの通常遷移は Turbo Frame を外した href でそのまま行く
      // newは data-turbo-frame="modal" なのでモーダル表示される
    });
  });
});

// スマホ専用「メニュー」モーダル
document.addEventListener("turbo:load", () => {
  const menuModal = document.getElementById("menu-modal");
  const menuModalContent = menuModal?.querySelector(".mobile-modal-content");

  if (!menuModal || !menuModalContent) return;

  // メニューを開く
  document.querySelectorAll(".open-menu-modal").forEach(btn => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();
      menuModal.style.display = "block";
    });
  });

  // 外側クリックで閉じる
  menuModal.addEventListener("click", (e) => {
    if (!menuModalContent.contains(e.target)) {
      menuModal.style.display = "none";
    }
  });
});
