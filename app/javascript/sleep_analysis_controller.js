import Chart from "chart.js/auto";

document.addEventListener("turbo:load", () => {
  const canvas = document.getElementById("dailySleepChart");
  if (!canvas) return;

  const labels = JSON.parse(canvas.dataset.dates || "[]");
  const daytime = JSON.parse(canvas.dataset.daytime || "[]");
  const nighttime = JSON.parse(canvas.dataset.nighttime || "[]");
  const naps = JSON.parse(canvas.dataset.naps || "[]");

  new Chart(canvas.getContext("2d"), {
    type: "bar",
    data: {
      labels: labels,
      datasets: [
        {
          label: "昼睡眠時間（分）",
          data: daytime,
          backgroundColor: "rgba(54, 162, 235, 0.5)"
        },
        {
          label: "夜睡眠時間（分）",
          data: nighttime,
          backgroundColor: "rgba(255, 206, 86, 0.5)"
        }
      ]
    },
    options: {
      responsive: true,
      plugins: {
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
        y: { beginAtZero: true }
      }
    }
  });
});