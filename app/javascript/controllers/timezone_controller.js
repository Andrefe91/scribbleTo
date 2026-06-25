import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="timezone"
export default class extends Controller {
  connect() {
    const tz = Intl.DateTimeFormat().resolvedOptions().timeZone
    document.cookie = `user_time_zone=${tz}; path=/; max-age=31536000; SameSite=Lax`
  }
}
