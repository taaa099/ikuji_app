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

  // === トグルボタンで状態を切り替え ===
  toggleBtn.addEventListener("click", () => {
    const isDesktop = window.innerWidth >= 1025;

    if (isDesktop) {
      sidebar.classList.toggle("collapsed");

      // 折りたたみ時・解除時どちらでもドロップダウンを閉じる
      if (recordListMenu) recordListMenu.classList.add("hidden");

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
    // 🔹 ページ読み込み時：保存状態を復元
    const savedDropdownState = localStorage.getItem("record-list-open");
    if (savedDropdownState === "true") {
      recordListMenu.classList.remove("hidden");
    }

    // 🔹 クリック時に開閉＋保存
    recordToggleBtn.addEventListener("click", () => {
      recordListMenu.classList.toggle("hidden");
      const isOpen = !recordListMenu.classList.contains("hidden");
      localStorage.setItem("record-list-open", isOpen);
    });
  }
});
