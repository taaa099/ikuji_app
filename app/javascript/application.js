// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"

import Rails from "@rails/ujs"
Rails.start();

// 通知機能用
import { showNotification } from "./notification_popup";
import "./notifications"

// 成長記録グラフ用
import "./growth_height";
import "./growth_weight";

// ダッシュボード表示用
import "./dashboard_chart";
