import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

document.addEventListener("turbo:load", function() {
  const ctx = document.getElementById("weightChart");
  if (!ctx) return;

  const growths = JSON.parse(ctx.dataset.growths || "[]");
  if (!growths.length) return;

  const minMonth = Math.min(...growths.map(g => g.month_age));
  const labels = growths.map(g => g.month_age - minMonth); // 最小月齢を0にして相対月齢にする
  const weightData = growths.map(g => g.weight);

  // 標準範囲（SD±2）
  const weightSD2Upper = [4.0, 4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 7.3, 7.6, 7.9, 8.1, 8.4, 8.6];
  const weightSD2Lower = [2.8, 3.2, 3.6, 4.0, 4.5, 4.9, 5.3, 5.6, 6.0, 6.3, 6.6, 6.8, 7.0];

  new Chart(ctx.getContext("2d"), {
    type: "line",
    data: {
      labels: labels,
      datasets: [
        {
          label: "体重標準範囲上限",
          data: weightSD2Upper,
          borderColor: "transparent",
          backgroundColor: "rgba(255,99,132,0.1)",
          fill: "+1"
        },
        {
          label: "体重標準範囲下限",
          data: weightSD2Lower,
          borderColor: "transparent",
          backgroundColor: "rgba(255,99,132,0.1)",
          fill: "-1"
        },
        {
          label: "体重(kg)",
          data: weightData,
          borderColor: "rgba(255, 99, 132, 1)",
          backgroundColor: "rgba(255, 99, 132, 0.2)",
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
            label: context => `${context.dataset.label}: ${context.parsed.y} kg`
          }
        },
        legend: { position: 'top' },
        title: { display: true, text: '乳児体重発育曲線' }
      },
      scales: {
        y: {
          title: { display: true, text: "体重(kg)" },
          beginAtZero: false
        },
        x: {
          title: { display: true, text: "月齢" }
        }
      }
    }
  });
});