document.addEventListener("turbo:load", () => {
  const sidebar = document.querySelector(".sidebar");
  const toggleBtn = document.getElementById("sidebar-toggle");
  const overlay = document.getElementById("sidebar-overlay");

  function isMobile() {
    return window.innerWidth <= 1024; // 1024px以下をモバイル扱い
  }

  if (toggleBtn && sidebar && overlay) {
    toggleBtn.addEventListener("click", () => {
      if (isMobile()) {
        sidebar.classList.toggle("open");
        overlay.classList.toggle("active");
      }
    });

    overlay.addEventListener("click", () => {
      sidebar.classList.remove("open");
      overlay.classList.remove("active");
    });
  }
});

document.addEventListener("turbo:load", () => {
  const toggleBtn = document.getElementById("toggle-record-list");
  const menu = document.getElementById("record-list-menu");

  if (toggleBtn && menu) {
    toggleBtn.addEventListener("click", () => {
      menu.classList.toggle("hidden");
    });
  }
});