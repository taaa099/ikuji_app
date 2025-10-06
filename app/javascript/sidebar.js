document.addEventListener("turbo:load", () => {
  const sidebar = document.querySelector(".sidebar");
  const toggleBtn = document.getElementById("sidebar-toggle");
  const overlay = document.getElementById("sidebar-overlay");

  if (!sidebar || !toggleBtn) return;

  toggleBtn.addEventListener("click", () => {
    if (window.innerWidth >= 1025) {
      sidebar.classList.toggle("collapsed");
    } else {
      sidebar.classList.toggle("open");
      overlay.classList.toggle("active");
    }
  });

  if (overlay) {
    overlay.addEventListener("click", () => {
      sidebar.classList.remove("open");ß
      overlay.classList.remove("active");
    });
  }

  // 育児記録一覧ドロップダウンの開閉処理
  const recordToggleBtn = document.getElementById("toggle-record-list");
  const recordListMenu = document.getElementById("record-list-menu");

  if (recordToggleBtn && recordListMenu) {
    recordToggleBtn.addEventListener("click", () => {
      recordListMenu.classList.toggle("hidden");
    });
  }
});