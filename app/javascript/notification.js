document.addEventListener("turbo:load", () => {
  const bell = document.getElementById("notification-bell");
  const dropdown = document.getElementById("notification-dropdown");
  const notificationWrapper = bell?.closest(".notification");

  // 他のドロップダウンも取得
  const recordIcons = document.getElementById("record-icons");
  const accountMenu = document.getElementById("account-menu");

  if (!bell || !dropdown || !notificationWrapper) return;

  // ベルクリック時
  bell.addEventListener("click", (e) => {
    e.stopPropagation();

    // まず他メニューを閉じる
    recordIcons?.classList.add("hidden");
    accountMenu?.classList.add("hidden");

    // 自身の開閉をトグル
    const isHidden = dropdown.classList.toggle("hidden");

    if (!isHidden) {
      notificationWrapper.classList.add("dropdown-open");

      // 開いた直後にスクロール位置を一番上に戻す
      dropdown.scrollTop = 0;

      // 開いたときのみ未読処理
      const url = bell.dataset.markAllAsReadUrl;
      fetch(url, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
          "Accept": "application/json"
        }
      })
        .then(() => {
          const countEl = bell.querySelector(".notification-count");
          if (countEl) countEl.remove();

          const unreadItems = dropdown.querySelectorAll(".notification-item.unread");
          unreadItems.forEach((item) => item.classList.remove("unread"));
        })
        .catch((err) => console.error(err));
    } else {
      notificationWrapper.classList.remove("dropdown-open");
    }
  });

  // 外クリックで閉じる
  document.addEventListener("click", (e) => {
    if (!notificationWrapper.contains(e.target)) {
      dropdown.classList.add("hidden");
      notificationWrapper.classList.remove("dropdown-open");
    }
  });
});