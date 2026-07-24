import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="check-locked-scribble"
export default class extends Controller {
  static targets = [
    "passwordCheck",
    "passwordField",
    "passwordWrapper",
    "eyeIcon",
    "eyeOffIcon",
    "submitButton",
    "error",
  ];

  connect() {
    this.switchPasswordField();
  }

  disconnect() {
    clearTimeout(this.timeout);
  }

  switchPasswordField() {
    const isPrivate =
      this.hasPasswordCheckTarget && this.passwordCheckTarget.checked;

    // Enable or disable input based on checkbox
    this.passwordFieldTarget.disabled = !isPrivate;

    if (!isPrivate) {
      clearTimeout(this.timeout); //Cancel validation if changed to Public
      this.passwordFieldTarget.classList.add(
        "opacity-50",
        "cursor-not-allowed",
      );
      this.clearError();
      this.enableSubmit(); // Protection turned off -> form submission allowed
    } else {
      this.passwordFieldTarget.classList.remove(
        "opacity-50",
        "cursor-not-allowed",
      );
      this.validate();
    }
  }

  debouncedValidate() {
    clearTimeout(this.timeout);

    this.timeout = setTimeout(() => {
      this.validate();
    }, 700); // Wait 1 second after the last keystroke
  }

  validate() {
    const isPrivate =
      this.hasPasswordCheckTarget && this.passwordCheckTarget.checked;
    if (!isPrivate) return;

    const password = this.passwordFieldTarget.value;

    if (password.length === 0) {
      this.clearError();
      this.disableSubmit();
    } else if (password.length >= 8) {
      this.clearError();
      this.enableSubmit();
    } else {
      this.showError("Write at least 8 characters");
      this.disableSubmit();
    }
  }

  showError(message) {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = message;
      this.errorTarget.classList.remove("hidden");
    }

    // Apply error border styling
    this.passwordFieldTarget.classList.add(
      "border-brand-error-border",
      "focus:ring-brand-error-border",
    );
    this.passwordFieldTarget.classList.remove(
      "border-grey-3",
      "focus:ring-brand-primary",
    );
  }

  clearError() {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = "";
      this.errorTarget.classList.add("hidden");
    }

    // Reset default border styling
    this.passwordFieldTarget.classList.remove(
      "border-brand-error-border",
      "focus:ring-brand-error-border",
    );
    this.passwordFieldTarget.classList.add(
      "border-grey-3",
      "focus:ring-brand-primary",
    );
  }

  togglePasswordVisibility(event) {
    event.preventDefault();

    const field = this.passwordFieldTarget;
    const isPassword = field.type === "password";

    field.type = isPassword ? "text" : "password";

    if (this.hasEyeIconTarget && this.hasEyeOffIconTarget) {
      this.eyeIconTarget.classList.toggle("hidden", isPassword);
      this.eyeOffIconTarget.classList.toggle("hidden", !isPassword);
    }
  }

  enableSubmit() {
    if (!this.hasSubmitButtonTarget) return;
    this.submitButtonTarget.disabled = false;
    this.submitButtonTarget.classList.remove(
      "disabled:opacity-25",
      "cursor-not-allowed",
    );
    this.submitButtonTarget.classList.add("cursor-pointer");
  }

  disableSubmit() {
    if (!this.hasSubmitButtonTarget) return;
    this.submitButtonTarget.disabled = true;
    this.submitButtonTarget.classList.add(
      "disabled:opacity-25",
      "cursor-not-allowed",
    );
    this.submitButtonTarget.classList.remove("cursor-pointer");
  }
}
