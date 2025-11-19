// ========================================
// 共通: モーダルを全て閉じる（except だけ除外）
// ========================================
function closeAllModals(except = null) {
  const modals = [
    document.getElementById("modal"),
    document.getElementById("deleteAccountModal"),
    document.getElementById("mobile-modal"),
    document.getElementById("menu-modal"),
    document.getElementById("notification-modal")
  ];

  modals.forEach(m => {
    if (!m || m === except) return;

    if (m.id === "modal") {
      m.innerHTML = "";
      return;
    }

    if (m.classList.contains("sidebar-modal")) {
      m.classList.add("hidden");
      return;
    }

    m.style.display = "none";
  });
}

// ========================================
// Turbo Frame モーダルが読み込まれたら他を閉じる
// ========================================
document.addEventListener("turbo:frame-load", (e) => {
  if (e.target.id === "modal") {
    closeAllModals(document.getElementById("modal"));
  }
});

// ========================================
// モーダル閉じる（TurboFrame）
// ========================================
document.addEventListener("click", (e) => {
  if (e.target.matches("#modal .modal-close")) {
    e.preventDefault();
    const modal = document.getElementById("modal");
    if (modal) modal.innerHTML = "";
  }
});

// ========================================
// 行クリック → TurboFrame モーダル
// ========================================
document.addEventListener("turbo:load", () => {
  document.addEventListener("click", (e) => {
    const row = e.target.closest(".clickable-row");
    if (!row) return;

    closeAllModals(); // ← 他を閉じてから開く

    const href = row.dataset.href;
    const turboFrame = row.dataset.turboFrame || "modal";
    Turbo.visit(href, { frame: turboFrame });
  });
});

// ========================================
// アカウント削除モーダル
// ========================================
document.addEventListener("turbo:load", () => {
  const modal = document.getElementById("deleteAccountModal");
  const openBtn = document.getElementById("deleteAccountBtn");
  const cancelBtn = document.getElementById("cancelDeleteBtn");

  if (!modal || !openBtn || !cancelBtn) return;

  openBtn.addEventListener("click", () => {
    closeAllModals(modal);
    modal.classList.remove("hidden");
  });

  cancelBtn.addEventListener("click", () => {
    modal.classList.add("hidden");
  });

  modal.addEventListener("click", (e) => {
    if (e.target === modal) modal.classList.add("hidden");
  });
});

// ========================================
// スマホ「記録一覧 / ＋」モーダル
// ========================================
document.addEventListener("turbo:load", () => {
  const mobileModal = document.getElementById("mobile-modal");
  const mobileModalContent = document.querySelector(".mobile-modal-content");
  const mobileModalTitle = document.getElementById("mobile-modal-title");

  if (!mobileModal || !mobileModalContent || !mobileModalTitle) return;

  const recordItems = mobileModalContent.querySelectorAll(".mobile-modal-item");

  document.querySelectorAll(".open-mobile-modal").forEach(btn => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();

      closeAllModals(mobileModal);

      const mode = btn.dataset.mode;

      recordItems.forEach(item => {
        const createHref = item.dataset.createHref;
        const indexHref = item.dataset.indexHref;

        if (mode === "list" && indexHref) {
          item.setAttribute("href", indexHref);
          item.removeAttribute("data-turbo-frame");
        } else if (mode === "create" && createHref) {
          item.setAttribute("href", createHref);
          item.setAttribute("data-turbo-frame", "modal");
        }
      });

      mobileModalTitle.textContent = mode === "list" ? "記録一覧" : "記録作成";
      mobileModal.style.display = "block";
    });
  });

  mobileModal.addEventListener("click", (e) => {
    if (!mobileModalContent.contains(e.target)) {
      mobileModal.style.display = "none";
    }
  });

  mobileModalContent.querySelectorAll("a").forEach(link => {
    link.addEventListener("click", () => {
      mobileModal.style.display = "none";
    });
  });
});

// ========================================
// スマホ「メニュー」モーダル
// ========================================
document.addEventListener("turbo:load", () => {
  const menuModal = document.getElementById("menu-modal");
  const menuModalContent = menuModal?.querySelector(".mobile-modal-content");

  if (!menuModal || !menuModalContent) return;

  document.querySelectorAll(".open-menu-modal").forEach(btn => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();

      closeAllModals(menuModal);

      menuModal.style.display = "block";
    });
  });

  menuModal.addEventListener("click", (e) => {
    if (!menuModalContent.contains(e.target)) {
      menuModal.style.display = "none";
    }
  });
});

// ========================================
// 通知設定モーダル
// ========================================
document.addEventListener("turbo:load", () => {
  const modal = document.getElementById("notification-modal");
  const contentBlock = document.getElementById("notification-settings-block");
  const closeBtn = document.getElementById("close-notification-modal");

  if (!modal || !contentBlock || !closeBtn) return;

  // 通知設定ボタンクリックで開く
  document.addEventListener("click", (e) => {
    if (e.target.closest("#toggle-notification-settings")) {
      closeAllModals(modal);

      modal.classList.remove("hidden");
      contentBlock.classList.remove("hidden");

      const container = modal.querySelector(".sidebar-modal-content");
      if (container) container.scrollTop = 0;
    }
  });

  // ❌ボタンクリックで閉じる
  closeBtn.addEventListener("click", () => {
    modal.classList.add("hidden");
    contentBlock.classList.add("hidden");
  });

  // モーダル外クリックで閉じる
  modal.addEventListener("click", (e) => {
    if (!contentBlock.contains(e.target)) {
      modal.classList.add("hidden");
      contentBlock.classList.add("hidden");
    }
  });
});