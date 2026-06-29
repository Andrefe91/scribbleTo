import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="block-trix-uploads"
export default class extends Controller {
	connect() {

		// Attach the listener locally to the element running the controller
		this.element.addEventListener("trix-file-accept", this.blockUploads);
	}

	disconnect() {
		// Clean up when the user leaves the page
		this.element.removeEventListener("trix-file-accept", this.blockUploads);
	}

	blockUploads(event) {
		event.preventDefault();
		alert("File or image attachments are not allowed!");
	}
}
