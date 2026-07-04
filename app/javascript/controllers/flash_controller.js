import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="flash"
export default class extends Controller {
  connect() {
    this.timeout = setTimeout(() => {
      this.dismiss()
    }, 2000) // 2 Seconds to dismissal
  }

  disconnect() {
    // Clean up the timer if the element is removed manually before the timeout hits
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  dismiss() {
    // Apply the fade-out/slide-down transitions smoothly
    this.element.style.opacity = "0"
    this.element.style.transform = "scale(0.95) translateY(10px)"

    // Wait for the CSS duration (500ms) before stripping it from the DOM
    setTimeout(() => {
      this.element.remove()
    }, 500)
  }
}
