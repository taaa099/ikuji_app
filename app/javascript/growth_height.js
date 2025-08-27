import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

document.addEventListener("turbo:load", function() {
  const ctx = document.getElementById("heightChart");
  if (!ctx) return;

  const growths = JSON.parse(ctx.dataset.growths || "[]");
  if (!growths.length) return;

  const minMonth = Math.min(...growths.map(g => g.month_age));
  const labels = growths.map(g => g.month_age - minMonth); // 最小月齢を0にして相対月齢にする
  const heightData = growths.map(g => g.height);

  // 標準範囲（SD±2）
  const heightSD2Upper = [53, 55, 57, 59, 61, 63, 65, 66, 68, 70, 72, 73, 75];
  const heightSD2Lower = [47, 49, 51, 53, 55, 57, 59, 60, 62, 63, 65, 66, 68];

  new Chart(ctx.getContext("2d"), {
    type: "line",
    data: {
      labels: labels,
      datasets: [
        {
          label: "身長標準範囲上限",
          data: heightSD2Upper,
          borderColor: "transparent",
          backgroundColor: "rgba(75,192,192,0.1)",
          fill: "+1"
        },
        {
          label: "身長標準範囲下限",
          data: heightSD2Lower,
          borderColor: "transparent",
          backgroundColor: "rgba(75,192,192,0.1)",
          fill: "-1"
        },
        {
          label: "身長(cm)",
          data: heightData,
          borderColor: "rgba(75, 192, 192, 1)",
          backgroundColor: "rgba(75, 192, 192, 0.2)",
          fill: false,
          tension: 0.4
        }
      ]
    },
    options: {
      responsive: true,
      plugins: {
        tooltip: {
          callbacks: {
            label: context => `${context.dataset.label}: ${context.parsed.y} cm`
          }
        },
        legend: { position: 'top' },
        title: { display: true, text: '乳児身長発育曲線' }
      },
      scales: {
        y: {
          title: { display: true, text: "身長(cm)" },
          beginAtZero: false
        },
        x: {
          title: { display: true, text: "月齢" }
        }
      }
    }
  });
});