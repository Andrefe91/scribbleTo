import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="check-locked-scribble"
export default class extends Controller {
	static targets = ["passwordCheck", "passwordField", "passwordWrapper", "eyeIcon", "eyeOffIcon"];

  connect() {
    this.switchPasswordField();
  }

	switchPasswordField() {
    // This is so the password field is locked or enabled when it should
		this.passwordFieldTarget.disabled = !this.passwordCheckTarget.checked;

    //And the styles for Tailwind
		if (this.passwordFieldTarget.disabled) {
			this.passwordFieldTarget.classList.add(
				"opacity-50",
				"cursor-not-allowed",
			);
		} else {
			this.passwordFieldTarget.classList.remove(
				"opacity-50",
				"cursor-not-allowed",
			);
		}
	}

	togglePasswordVisibility(event) {
    event.preventDefault()

    const field = this.passwordFieldTarget
    const isPassword = field.type === "password"

    // Toggle input type
    field.type = isPassword ? "text" : "password"

    // Toggle icon visibility
    if (this.hasEyeIconTarget && this.hasEyeOffIconTarget) {
      this.eyeIconTarget.classList.toggle("hidden", isPassword)
      this.eyeOffIconTarget.classList.toggle("hidden", !isPassword)
    }
  }
}
