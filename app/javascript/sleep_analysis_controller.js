import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

let sleepChart;

function createSleepChart(isDarkMode) {
  const canvas = document.getElementById("dailySleepChart");
  if (!canvas) return;

  const labels = JSON.parse(canvas.dataset.dates || "[]");
  const daytime = JSON.parse(canvas.dataset.daytime || "[]");
  const nighttime = JSON.parse(canvas.dataset.nighttime || "[]");
  const naps = JSON.parse(canvas.dataset.naps || "[]");

  const textColor = isDarkMode ? "#fff" : "#333";
  const gridColor = isDarkMode ? "#374151" : "#ccc";

  if (sleepChart) sleepChart.destroy();

  sleepChart = new Chart(canvas.getContext("2d"), {
    type: "bar",
    data: {
      labels: labels,
      datasets: [
        {
          label: "昼睡眠時間（分）",
          data: daytime,
          backgroundColor: isDarkMode ? "rgba(96, 165, 250, 0.6)" : "rgba(54, 162, 235, 0.5)" // 明るい青
        },
        {
          label: "夜睡眠時間（分）",
          data: nighttime,
          backgroundColor: isDarkMode ? "rgba(250, 204, 21, 0.6)" : "rgba(255, 206, 86, 0.5)" // 黄色系
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: { labels: { color: textColor } },
        title: { display: true, text: "日別睡眠分析", color: textColor },
        tooltip: {
          callbacks: {
            afterBody: function(context) {
              const idx = context[0].dataIndex;
              return `昼寝回数: ${naps[idx]} 回`;
            }
          }
        }
      },
      scales: {
        x: {
          ticks: { color: textColor },
          grid: { color: gridColor }
        },
        y: {
          beginAtZero: true,
          ticks: { color: textColor },
          grid: { color: gridColor },
          title: { display: true, text: "睡眠時間（分）", color: textColor }
        }
      }
    }
  });
}

window.createSleepChart = createSleepChart; // ダークモード切替から呼べるようにグローバル化