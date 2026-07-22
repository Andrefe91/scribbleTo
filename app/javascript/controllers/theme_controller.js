import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  connect() {
    const savedTheme = localStorage.getItem("theme") || "light"
    this.applyTheme(savedTheme)
  }

  switch(event) {
    const theme = event.currentTarget.dataset.themeName
    this.applyTheme(theme)
  }

  applyTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)
    localStorage.setItem("theme", theme)

    // Fallback if you still want traditional Tailwind dark: class behavior
    if (theme === "dark") {
      document.documentElement.classList.add("dark")
    } else {
      document.documentElement.classList.remove("dark")
    }
  }
}
