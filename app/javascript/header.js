document.addEventListener("turbo:load", () => {
  // アカウントメニュー開閉
  const accountToggle = document.getElementById("account-toggle");
  const accountMenu = document.getElementById("account-menu");

  if (accountToggle && accountMenu) {
    accountToggle.addEventListener("click", (e) => {
      e.preventDefault();
      accountMenu.classList.toggle("hidden");
    });

    // 外側クリックで閉じる
    document.addEventListener("click", (e) => {
      if (!accountToggle.contains(e.target) && !accountMenu.contains(e.target)) {
        accountMenu.classList.add("hidden");
      }
    });
  }
});


document.addEventListener("turbo:load", () => {
  const toggle = document.getElementById("child-toggle");
  const menu = document.getElementById("child-menu");

  if (toggle && menu) {
    toggle.addEventListener("click", () => {
      menu.classList.toggle("hidden");
    });

    // メニュー外クリックで閉じる
    document.addEventListener("click", (e) => {
      if (!toggle.contains(e.target) && !menu.contains(e.target)) {
        menu.classList.add("hidden");
      }
    });
  }
});

document.addEventListener("DOMContentLoaded", () => {
  const newRecordButton = document.getElementById("new-record-button");
  const recordIcons = document.getElementById("record-icons");

  // 作成ボタン押したらトグル
  newRecordButton.addEventListener("click", () => {
    recordIcons.classList.toggle("hidden");
  });

  // ドロップダウン内リンク押したら閉じる
  recordIcons.querySelectorAll("a").forEach((link) => {
    link.addEventListener("click", () => {
      recordIcons.classList.add("hidden");
    });
  });

  // 画面クリックでドロップダウン閉じる（オプション）
  document.addEventListener("click", (e) => {
    if (!recordIcons.contains(e.target) && e.target !== newRecordButton) {
      recordIcons.classList.add("hidden");
    }
  });
});