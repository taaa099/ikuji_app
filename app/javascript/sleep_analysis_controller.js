import Chart from "chart.js/auto";

document.addEventListener("turbo:load", () => {
  const canvas = document.getElementById("weeklySleepChart");
  if (!canvas) return;

  const labels = JSON.parse(canvas.dataset.labels || "[]");
  const values = JSON.parse(canvas.dataset.values || "[]");

  new Chart(canvas.getContext("2d"), {
    type: "bar",
    data: {
      labels: labels,
      datasets: [{
        label: "週別合計睡眠時間（分）",
        data: values,
        backgroundColor: "rgba(54, 162, 235, 0.5)"
      }]
    },
    options: {
      responsive: true,
      scales: {
        y: { beginAtZero: true }
      }
    }
  });
});