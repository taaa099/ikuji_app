document.addEventListener("turbo:load", () => {
  const sidebar = document.querySelector(".sidebar");
  const toggleBtn = document.getElementById("sidebar-toggle");
  const overlay = document.getElementById("sidebar-overlay");

  if (!sidebar || !toggleBtn) return;

  // === 保存された状態を適用 ===
  const savedState = localStorage.getItem("sidebar-collapsed");
  if (savedState === "true") {
    sidebar.classList.add("collapsed");
  }

  // === ドロップダウン要素の参照 ===
  const recordListMenu = document.getElementById("record-list-menu");
  const notificationBlock = document.getElementById("notification-settings-block");

  // === トグルボタンで状態を切り替え ===
  toggleBtn.addEventListener("click", () => {
    const isDesktop = window.innerWidth >= 1025;

    if (isDesktop) {
      sidebar.classList.toggle("collapsed");

      // 折りたたみ時・解除時どちらでもドロップダウンを閉じる
      if (recordListMenu) recordListMenu.classList.add("hidden");
      if (notificationBlock) notificationBlock.style.display = "none";

      // 状態を保存
      localStorage.setItem(
        "sidebar-collapsed",
        sidebar.classList.contains("collapsed")
      );
    } else {
      sidebar.classList.toggle("open");
      overlay.classList.toggle("active");

      // モバイル時も開閉のたびにドロップダウンを閉じる
      if (recordListMenu) recordListMenu.classList.add("hidden");
      if (notificationBlock) notificationBlock.style.display = "none";
    }
  });

  // === モバイル用オーバーレイ ===
  if (overlay) {
    overlay.addEventListener("click", () => {
      sidebar.classList.remove("open");
      overlay.classList.remove("active");
    });
  }

  // === 育児記録一覧ドロップダウン ===
  const recordToggleBtn = document.getElementById("toggle-record-list");
  if (recordToggleBtn && recordListMenu) {
    recordToggleBtn.addEventListener("click", () => {
      recordListMenu.classList.toggle("hidden");
    });
  }

  // === 通知設定ドロップダウン ===
  const notificationToggleBtn = document.getElementById("toggle-notification-settings");
  if (notificationToggleBtn && notificationBlock) {
    notificationToggleBtn.addEventListener("click", () => {
      notificationBlock.style.display =
        notificationBlock.style.display === "none" || notificationBlock.style.display === ""
          ? "block"
          : "none";
    });
  }
});