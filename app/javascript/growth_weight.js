import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

let weightChart;

function createWeightChart(isDarkMode) {
  const ctx = document.getElementById("weightChart");
  if (!ctx) return;

  const growths = JSON.parse(ctx.dataset.growths || "[]");
  if (!growths.length) {
    const parent = ctx.closest("div");
    if (parent) parent.remove();
    return;
  }

  const minMonth = Math.min(...growths.map(g => g.month_age));
  const labels = growths.map(g => g.month_age - minMonth);
  const weightData = growths.map(g => g.weight);

  const weightSD2Upper = [4.0, 4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 7.3, 7.6, 7.9, 8.1, 8.4, 8.6];
  const weightSD2Lower = [2.8, 3.2, 3.6, 4.0, 4.5, 4.9, 5.3, 5.6, 6.0, 6.3, 6.6, 6.8, 7.0];

  const textColor = isDarkMode ? "#fff" : "#333";
  const gridColor = isDarkMode ? "#374151" : "#ccc";

  if (weightChart) weightChart.destroy();

  weightChart = new Chart(ctx.getContext("2d"), {
    type: "line",
    data: {
      labels,
      datasets: [
        { label: "体重標準範囲上限", data: weightSD2Upper, borderColor: "transparent", backgroundColor: "rgba(255,99,132,0.1)", fill: "+1" },
        { label: "体重標準範囲下限", data: weightSD2Lower, borderColor: "transparent", backgroundColor: "rgba(255,99,132,0.1)", fill: "-1" },
        { label: "体重(kg)", data: weightData, borderColor: isDarkMode ? "#facc15" : "#f59e0b", backgroundColor: isDarkMode ? "#facc1555" : "#f59e0b55", fill: false, tension: 0.4 }
      ]
    },
    options: {
      responsive: true,
       maintainAspectRatio: false,
      plugins: {
        legend: { labels: { color: textColor } },
        title: { display: true, text: "乳児体重発育曲線", color: textColor },
        tooltip: { callbacks: { label: ctx => `${ctx.dataset.label}: ${ctx.parsed.y} kg` } }
      },
      scales: {
        x: { title: { display: true, text: "月齢", color: textColor }, ticks: { color: textColor }, grid: { color: gridColor } },
        y: { title: { display: true, text: "体重(kg)", color: textColor }, ticks: { color: textColor }, grid: { color: gridColor } }
      }
    }
  });
}

window.createWeightChart = createWeightChart;