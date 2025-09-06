import consumer from "./consumer"
import { showNotification } from "../notification_popup"

function subscribeNotifications() {
  if (window.notificationSubscription) return;
  console.log("subscribeNotifications running")

  const childId = document.body.dataset.currentChildId
  console.log("Subscribing to childId:", childId)
  if (!childId || childId === "0") return;

  window.notificationSubscription = consumer.subscriptions.create(
    { channel: "NotificationChannel", id: childId },
    {
      connected() {
        console.log("Action Cable connected!") // サーバーと接続できたか
      },
      received(data) {
        console.log("received data:", data) // サーバーから送られた通知が入る
        showNotification(data.title, data.message, data.notification_kind)
      },
      disconnected() {
        console.log("Action Cable disconnected") // 切断された場合
      }
    }
  )
}

document.addEventListener("turbo:load", subscribeNotifications)