document.addEventListener("turbo:load", () => {
  const sidebar = document.querySelector(".sidebar");
  const toggleBtn = document.getElementById("sidebar-toggle");
  const overlay = document.getElementById("sidebar-overlay");

  if (!sidebar || !toggleBtn) return;

  toggleBtn.addEventListener("click", () => {
    if (window.innerWidth >= 1025) {
      // PCはcollapsedで切替
      sidebar.classList.toggle("collapsed");
    } else {
      // モバイルは開閉
      sidebar.classList.toggle("open");
      overlay.classList.toggle("active");
    }
  });

  if (overlay) {
    overlay.addEventListener("click", () => {
      sidebar.classList.remove("open");
      overlay.classList.remove("active");
    });
  }
});