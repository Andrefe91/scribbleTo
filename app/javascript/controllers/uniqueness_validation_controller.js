import { Controller } from "@hotwired/stimulus";
import normalizeName from "../normalizeName.js";

// Connects to data-controller="uniqueness-validation"
export default class extends Controller {
	static targets = ["input", "error", "submitButton"];
	static RESERVED_WORDS = Object.freeze(["admin", "assets", "api", "about", "contact", "help", "support", "login", "logout", "signup", "settings"]);

	static isReserved(word) {
		return this.RESERVED_WORDS.includes(word.toLowerCase());
	}

	connect() {
		this.timeout = null;
	}

	// Debounce the uniqueness check to avoid too many requests
	checkWithDelay() {
		clearTimeout(this.timeout);

		this.timeout = setTimeout(() => {
			this.checkUniqueName();
		}, 1000); //1 seg delay to avoid too many requests
	}

	async checkUniqueName(event) {
		this.inputTarget.value = normalizeName(this.inputTarget.value); // Update the input value with the normalized name
		const name = normalizeName(this.inputTarget.value.trim());

		if (!name) {
			this.clearError();
			return;
		}

		if (this.constructor.isReserved(name)) {
			this.showError("Sorry, this name is reserved and cannot be used");
			return;
		}

		try {
			// Fetch uniqueness state from our Rails endpoint
			const response = await fetch(
				`/scribbles/check_uniqueness?name=${encodeURIComponent(name)}`,
			);

			if (!response.ok) {
				const errorText = await response.json();
				this.showError(
					errorText.error ||
						"An error occurred on our end. Please try again later.",
				);
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

    // Disable the submit button if it exists
		if (this.hasSubmitButtonTarget) {
			this.submitButtonTarget.disabled = true;
			this.submitButtonTarget.classList.add(
				"disabled:opacity-25",
				"cursor-not-allowed",
			);
			this.submitButtonTarget.classList.remove("cursor-pointer");
		}
	}

	clearError() {
		this.errorTarget.textContent = "";
		this.errorTarget.classList.add("hidden");
		this.inputTarget.classList.remove("border-red-500", "focus:ring-red-500");
		this.inputTarget.classList.add("border-gray-300", "focus:ring-sky-500");

    // Enable the submit button if it exists
		if (this.hasSubmitButtonTarget) {
			this.submitButtonTarget.disabled = false;
			this.submitButtonTarget.classList.remove(
				"disabled:opacity-25",
				"cursor-not-allowed",
			);
			this.submitButtonTarget.classList.add("cursor-pointer");
		}
	}
}
