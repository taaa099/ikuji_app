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
});