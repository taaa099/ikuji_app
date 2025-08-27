import { Chart, registerables } from "chart.js";
Chart.register(...registerables);

document.addEventListener("turbo:load", function() {
  const ctx = document.getElementById("dashboardChart");
  if (!ctx) return;

  const growths = JSON.parse(ctx.dataset.growths || "[]");
  if (!growths.length) return;

  const minMonth = Math.min(...growths.map(g => g.month_age));
  const labels = growths.map(g => g.month_age - minMonth);

  const heightData = growths.map(g => g.height);
  const weightData = growths.map(g => g.weight);

  new Chart(ctx.getContext("2d"), {
    type: "line",
    data: {
      labels: labels,
      datasets: [
        { label: "身長(cm)", data: heightData, borderColor: "blue", fill: false, tension: 0.4 },
        { label: "体重(kg)", data: weightData, borderColor: "green", fill: false, tension: 0.4 }
      ]
    },
    options: {
      responsive: true,
      plugins: { legend: { position: 'top' }, title: { display: true, text: '成長ダッシュボード' } },
      scales: { 
        y: { title: { display: true, text: "数値" }, beginAtZero: false },
        x: { title: { display: true, text: "月齢" } }
      }
    }
  });
});