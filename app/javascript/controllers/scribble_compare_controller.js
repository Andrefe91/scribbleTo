import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="scribble-compare"
export default class extends Controller {
  static targets = [ "status", "submitButton" ]
  static classes = [ "enabled", "disabled" ]
  // Dirty tracking the body Value
  static values = { originalBody: String }

  connect() {
    this.stateInit();
  }

  checkChanges(event) {
    const currentBody = event.target.editor.getDocument().toString().trim()

    if (currentBody === this.originalBodyValue) {
      this.statusTarget.textContent = "No Change";
      this.makeDisabled();
    } else {
      this.statusTarget.textContent = "You have unsaved changes!";
      this.makeEnabled();
    }
  }

  // Needs for initial state on the Show page
  stateInit() {
    this.statusTarget.textContent = "No Change" // Initial State of Message
    this.makeDisabled(); //Initial state of the Update Scribble button
  }

  //Logic to manage and alter the classes for the Update Button on the SHOW Scribble page
  makeEnabled() {
    this.submitButtonTarget.disabled = false

    this.submitButtonTarget.classList.remove(...this.disabledClasses)
    this.submitButtonTarget.classList.add(...this.enabledClasses)
  }

  makeDisabled() {
    this.submitButtonTarget.disabled = true

    this.submitButtonTarget.classList.remove(...this.enabledClasses)
    this.submitButtonTarget.classList.add(...this.disabledClasses)
  }
}
