// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"

import Rails from "@rails/ujs"
Rails.start();

// 通知機能用
import { showNotification } from "./notification_popup";
import "./channels"
import "./notification_settings"

// 成長記録グラフ用
import "./growth_height";
import "./growth_weight";

// ダッシュボード表示用
import "./dashboard_chart";

// 睡眠分析表示用
import "./sleep_analysis_controller";

// モーダル表示用
import "./modal";

// フラッシュ表示用
import "./flash";

//ダークモード表示用
import "./dark_mode";

//サイドバー表示用
import "./sidebar";

//ヘッダー機能関連
import "./header";
