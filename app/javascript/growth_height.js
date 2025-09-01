import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

let dashboardChart;

function createDashboardChart(isDarkMode) {
  const ctx = document.getElementById("dashboardChart");
  if (!ctx) return;

  const growths = JSON.parse(ctx.dataset.growths || "[]");
  if (!growths.length) return;

  const minMonth = Math.min(...growths.map(g => g.month_age));
  const labels = growths.map(g => g.month_age - minMonth);

  const heightData = growths.map(g => g.height);
  const weightData = growths.map(g => g.weight);

  const textColor = isDarkMode ? "#fff" : "#333";
  const gridColor = isDarkMode ? "#374151" : "#ccc";

  if (dashboardChart) dashboardChart.destroy();

  dashboardChart = new Chart(ctx.getContext("2d"), {
    type: "line",
    data: {
      labels,
      datasets: [
        {
          label: "身長(cm)",
          data: heightData,
          borderColor: isDarkMode ? "#60a5fa" : "#3b82f6",
          backgroundColor: isDarkMode ? "#60a5fa55" : "#3b82f655",
          fill: false,
          tension: 0.4
        },
        {
          label: "体重(kg)",
          data: weightData,
          borderColor: isDarkMode ? "#34d399" : "#10b981",
          backgroundColor: isDarkMode ? "#34d39955" : "#10b98155",
          fill: false,
          tension: 0.4
        }
      ]
    },
    options: {
      responsive: true,
      plugins: {
        legend: { labels: { color: textColor } },
        title: { display: true, text: "成長ダッシュボード", color: textColor },
        tooltip: {
          callbacks: {
            label: ctx => `${ctx.dataset.label}: ${ctx.parsed.y} ${ctx.dataset.label === "身長(cm)" ? "cm" : "kg"}`
          }
        }
      },
      scales: {
        x: { title: { display: true, text: "月齢", color: textColor }, ticks: { color: textColor }, grid: { color: gridColor } },
        y: { title: { display: true, text: "数値", color: textColor }, ticks: { color: textColor }, grid: { color: gridColor } }
      }
    }
  });
}

window.createDashboardChart = createDashboardChart;