import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="uniqueness-validation"
export default class extends Controller {
  static targets = ["input", "error"];

  connect() {
    this.timeout = null;
  }

  // Debounce the uniqueness check to avoid too many requests
  checkWithDelay() {
    clearTimeout(this.timeout);

    this.timeout = setTimeout(() => {
      this.checkUniqueName();
    }, 400) //400 ms delay to avoid too many requests
  }

  async checkUniqueName(event) {
    const name = this.inputTarget.value.trim();

    if (!name) {
      this.clearError();
      return;
    }

    try {
      // Fetch uniqueness state from our Rails endpoint
      const response = await fetch(`/scribbles/check_uniqueness?name=${encodeURIComponent(name)}`);

      if (!response.ok) {
        const errorText = await response.json();
        this.showError(errorText.error || "An error occurred on our end. Please try again later.");
        return;
      }

      const data = await response.json();

      if (!data.unique) {
        this.showError("This name is already taken.");
      } else {
        this.clearError();
      }
    } catch (error) {
      console.error("Error validating uniqueness:", error);
    }
  }

  showError(message) {
    this.errorTarget.textContent = message;
    this.errorTarget.classList.remove("hidden");
    this.inputTarget.classList.add("border-red-500", "focus:ring-red-500");
    this.inputTarget.classList.remove("border-gray-300", "focus:ring-sky-500");
  }

  clearError() {
    this.errorTarget.textContent = "";
    this.errorTarget.classList.add("hidden");
    this.inputTarget.classList.remove("border-red-500", "focus:ring-red-500");
    this.inputTarget.classList.add("border-gray-300", "focus:ring-sky-500");
  }
}
