// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"

import Rails from "@rails/ujs"
Rails.start();

import { showNotification } from "./notification_popup";
import "./notifications"
