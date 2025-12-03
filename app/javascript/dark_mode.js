document.addEventListener("turbo:load", () => {
  const toggle = document.getElementById("theme-toggle");
  const menu = document.getElementById("theme-menu");
  const lightCheckbox = document.getElementById("theme-light");
  const darkCheckbox = document.getElementById("theme-dark");

  // bodyのdata-logged-in属性を参照
  const isLoggedIn = document.body.dataset.loggedIn === "true";
  if (!isLoggedIn) {
    localStorage.removeItem("theme");              // 保存されているテーマを削除
    document.documentElement.classList.remove("dark"); // darkクラスを削除
  }
  // ==============================

  // 保存されているテーマを反映
  let savedTheme = localStorage.getItem("theme") || "light";
  let isDark = savedTheme === "dark";

  if (isDark) {
    document.documentElement.classList.add("dark");
    darkCheckbox.checked = true;
    lightCheckbox.checked = false;
  } else {
    document.documentElement.classList.remove("dark");
    lightCheckbox.checked = true;
    darkCheckbox.checked = false;
  }

  // ページロード時にチャート再描画
  if (typeof createHeightChart === "function") createHeightChart(isDark);
  if (typeof createWeightChart === "function") createWeightChart(isDark);
  if (typeof createDashboardChart === "function") createDashboardChart(isDark);
  if (typeof createSleepChart === "function") createSleepChart(isDark);

  // ドロップダウン開閉
  if (toggle && menu) {
    toggle.addEventListener("click", (e) => {
      e.preventDefault();
      menu.classList.toggle("hidden");
    });

    document.addEventListener("click", (e) => {
      if (!toggle.contains(e.target) && !menu.contains(e.target)) {
        menu.classList.add("hidden");
      }
    });

    // テーマリンククリック時
    menu.querySelectorAll("a").forEach((link) => {
      link.addEventListener("click", (e) => {
        e.preventDefault();
        const theme = link.dataset.theme;

        const isDark = theme === "dark";
        if (isDark) {
          document.documentElement.classList.add("dark");
          darkCheckbox.checked = true;
          lightCheckbox.checked = false;
        } else {
          document.documentElement.classList.remove("dark");
          lightCheckbox.checked = true;
          darkCheckbox.checked = false;
        }

        localStorage.setItem("theme", theme);

        // チャート再描画
        if (typeof createHeightChart === "function") createHeightChart(isDark);
        if (typeof createWeightChart === "function") createWeightChart(isDark);
        if (typeof createDashboardChart === "function") createDashboardChart(isDark);
        if (typeof createSleepChart === "function") createSleepChart(isDark);
      });
    });
  }

  // ログアウト時にダークモード解除
  const logoutLink = document.querySelector('a[href="/users/sign_out"]');
  if (logoutLink) {
    logoutLink.addEventListener("click", () => {
      localStorage.removeItem("theme");              // 保存されているテーマを削除
      document.documentElement.classList.remove("dark"); // darkクラスを削除
    });
  }
});