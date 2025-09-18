// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"

import Rails from "@rails/ujs"
Rails.start();

// 通知機能用
import { showNotification } from "./notification_popup";
import "./channels"
import "./notification_settings"

// 成長記録グラフ用
import "./growth_height";
import "./growth_weight";

// ダッシュボード表示用
import "./dashboard_chart";

// 睡眠分析表示用
import "./sleep_analysis_controller";

// 共通：ダークモード管理
document.addEventListener("turbo:load", () => {
  const toggle = document.getElementById("dark-mode-toggle");

  const isDark = localStorage.getItem("darkMode") === "true";
  document.documentElement.classList.toggle("dark", isDark);

  if (typeof createHeightChart === "function") createHeightChart(isDark);
  if (typeof createWeightChart === "function") createWeightChart(isDark);
  if (typeof createDashboardChart === "function") createDashboardChart(isDark);
  if (typeof createSleepChart === "function") createSleepChart(isDark);

  if (toggle) {
    toggle.addEventListener("click", () => {
      const isDarkNow = !document.documentElement.classList.contains("dark");
      document.documentElement.classList.toggle("dark");
      localStorage.setItem("darkMode", isDarkNow);

      if (typeof createHeightChart === "function") createHeightChart(isDarkNow);
      if (typeof createWeightChart === "function") createWeightChart(isDarkNow);
      if (typeof createDashboardChart === "function") createDashboardChart(isDarkNow);
      if (typeof createSleepChart === "function") createSleepChart(isDarkNow);
    });
  }

  // サイドバー開閉
  const sidebar = document.querySelector(".sidebar");
  const toggleBtn = document.getElementById("sidebar-toggle");
  const overlay = document.getElementById("sidebar-overlay");

  if (toggleBtn && sidebar && overlay) {
    toggleBtn.addEventListener("click", () => {
      sidebar.classList.toggle("open");
      overlay.classList.toggle("active");
    });

    overlay.addEventListener("click", () => {
      sidebar.classList.remove("open");
      overlay.classList.remove("active");
    });
  }
});