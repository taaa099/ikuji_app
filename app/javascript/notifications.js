import { showNotification } from "./notification_popup"

document.addEventListener("turbo:load", () => {
  const childId = document.body.dataset.currentChildId; // bodyにdata-current-child-idがセットされている場合
  if (!childId) return;

  // 最新通知を取得
  fetch(`/notifications/latest?child_id=${childId}`)
    .then(response => response.json())
    .then(data => {
      if (data && data.id) {
        // ポップアップ表示
        showNotification(data.title, data.message)
    
      }
    })
    .catch(error => console.error("通知取得エラー:", error))
})

document.addEventListener("turbo:load", () => {
  console.log("turbo:load fired"); // turbo:load イベントが発火するか確認
  const childId = document.body.dataset.currentChildId;
  console.log("childId:", childId); // body から childId を取得できているか確認
});