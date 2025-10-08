document.addEventListener("turbo:load", () => {
  // NotificationSetting のオンオフ・数値
  document.querySelectorAll(".notification-switch, .notification-number, .notification-time").forEach((input) => {
    input.addEventListener("change", (e) => {
      const id = e.target.dataset.id;
      const field = e.target.dataset.field;
      const value = e.target.type === "checkbox" ? e.target.checked : e.target.value;

      fetch(`/notification_settings/${id}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content
        },
        body: JSON.stringify({
          notification_setting: { [field]: value }
        })
      }).then(res => res.json())
        .then(data => {
          if (!data.success) alert("更新失敗: " + data.errors.join(", "));
        });
    });
  });

  // Children daily_goal 更新
  document.querySelectorAll(".child-goal").forEach((input) => {
    input.addEventListener("change", (e) => {
      const childId = e.target.dataset.childId;
      const field = e.target.dataset.field;
      const value = e.target.value;

      fetch(`/children/${childId}/update_daily_goal`, {   // ← 修正済み
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content
        },
        body: JSON.stringify({
          child: { [field]: value }
        })
      }).then(res => res.json())
        .then(data => {
          if (!data.success) alert("更新失敗: " + data.errors.join(", "));
        });
    });
  });
});

document.addEventListener("turbo:load", () => {
  const toggleNotificationBtn = document.getElementById("toggle-notification-settings");
  const notificationBlock = document.getElementById("notification-settings-block");

  if (toggleNotificationBtn && notificationBlock) {
    // ✅ イベント重複を防止しつつ、置換しないよう修正
    if (!toggleNotificationBtn.dataset.initialized) {
      toggleNotificationBtn.addEventListener("click", () => {
        notificationBlock.classList.toggle("hidden");
      });
      toggleNotificationBtn.dataset.initialized = "true";
    }
  }
});