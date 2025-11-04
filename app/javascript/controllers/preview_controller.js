import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="preview"
export default class extends Controller {
  show(event) {
    const files = event.target.files
    const container = document.querySelector("#current-media-container")

    if (!container) return

    // 既存プレビューを消さずに追記
    Array.from(files).forEach(file => {
      const reader = new FileReader()
      reader.onload = e => {
        const isImage = file.type.startsWith("image/")
        const preview = document.createElement(isImage ? "img" : "video")
        preview.classList.add("media-thumb")
        preview.src = e.target.result
        if (!isImage) preview.setAttribute("controls", "true")
        container.appendChild(preview)
      }
      reader.readAsDataURL(file)
    })
  }
}