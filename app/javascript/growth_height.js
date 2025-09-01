import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

let heightChart;

function createHeightChart(isDarkMode) {
  const ctx = document.getElementById("heightChart");
  if (!ctx) return;

  const growths = JSON.parse(ctx.dataset.growths || "[]");
  if (!growths.length) return;

  const minMonth = Math.min(...growths.map(g => g.month_age));
  const labels = growths.map(g => g.month_age - minMonth);
  const heightData = growths.map(g => g.height);

  const heightSD2Upper = [53, 55, 57, 59, 61, 63, 65, 66, 68, 70, 72, 73, 75];
  const heightSD2Lower = [47, 49, 51, 53, 55, 57, 59, 60, 62, 63, 65, 66, 68];

  const textColor = isDarkMode ? "#fff" : "#333";
  const gridColor = isDarkMode ? "#374151" : "#ccc";

  if (heightChart) heightChart.destroy();

  heightChart = new Chart(ctx.getContext("2d"), {
    type: "line",
    data: {
      labels,
      datasets: [
        { label: "身長標準範囲上限", data: heightSD2Upper, borderColor: "transparent", backgroundColor: "rgba(75,192,192,0.1)", fill: "+1" },
        { label: "身長標準範囲下限", data: heightSD2Lower, borderColor: "transparent", backgroundColor: "rgba(75,192,192,0.1)", fill: "-1" },
        { label: "身長(cm)", data: heightData, borderColor: isDarkMode ? "#60a5fa" : "#3b82f6", backgroundColor: isDarkMode ? "#60a5fa55" : "#3b82f655", fill: false, tension: 0.4 }
      ]
    },
    options: {
      responsive: true,
      plugins: {
        legend: { labels: { color: textColor } },
        title: { display: true, text: "乳児身長発育曲線", color: textColor },
        tooltip: { callbacks: { label: ctx => `${ctx.dataset.label}: ${ctx.parsed.y} cm` } }
      },
      scales: {
        x: { title: { display: true, text: "月齢", color: textColor }, ticks: { color: textColor }, grid: { color: gridColor } },
        y: { title: { display: true, text: "身長(cm)", color: textColor }, ticks: { color: textColor }, grid: { color: gridColor } }
      }
    }
  });
}

window.createHeightChart = createHeightChart;