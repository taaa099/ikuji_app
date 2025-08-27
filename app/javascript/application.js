// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"

import Rails from "@rails/ujs"
Rails.start();

import { showNotification } from "./notification_popup";
import "./notifications"

import { Chart, registerables } from "chart.js";
Chart.register(...registerables);


document.addEventListener("DOMContentLoaded", () => {
  const ctx = document.getElementById("myChart");
  if (ctx) {
    new Chart(ctx, {
      type: "bar",
      data: {
        labels: ["Red", "Blue", "Yellow"],
        datasets: [{
          label: "# of Votes",
          data: [12, 19, 3],
          backgroundColor: ["red", "blue", "yellow"]
        }]
      },
      options: {}
    });
  }
});