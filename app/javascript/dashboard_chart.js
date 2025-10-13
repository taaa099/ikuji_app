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
      labels: labels,
      datasets: [
        { label: "身長(cm)", data: heightData, borderColor: isDarkMode ? "skyblue" : "blue", fill: false, tension: 0.4 },
        { label: "体重(kg)", data: weightData, borderColor: isDarkMode ? "lightgreen" : "green", fill: false, tension: 0.4 }
      ]
    },
    options: {
      responsive: true,
      plugins: { 
        legend: { position: 'top', labels: { color: textColor } }, 
        title: { display: true, text: '成長ダッシュボード', color: textColor } 
      },
      scales: { 
        y: { title: { display: true, text: "数値", color: textColor }, ticks: { color: textColor }, grid: { color: gridColor }, beginAtZero: false },
        x: { title: { display: true, text: "月齢", color: textColor }, ticks: { color: textColor }, grid: { color: gridColor } }
      }
    }
  });
}

window.createDashboardChart = createDashboardChart; // ダークモード切替から呼べるようにグローバル化

  document.addEventListener("turbo:load", () => {
    const button = document.getElementById("calendar-button");
    const input = document.getElementById("calendar-input");

    if (button && input) {
      button.addEventListener("click", () => {
        input.showPicker(); // ✅ ボタンクリックで直接カレンダーを開く
      });

      input.addEventListener("change", () => {
        const selectedDate = input.value;
        if (selectedDate) {
          // ✅ 選択された日付にリダイレクト
          window.location.href = `/?date=${selectedDate}`;
        }
      });
    }
  });