import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="theme"
export default class extends Controller {
	static themes = ["light", "dark", "retro"];

	toggle() {
		const currentTheme =
			document.documentElement.getAttribute("data-theme") || "light";

		const currentIndex = this.constructor.themes.indexOf(currentTheme);
		const nextIndex = (currentIndex + 1) % this.constructor.themes.length;
		const nextTheme = this.constructor.themes[nextIndex];

		document.documentElement.setAttribute("data-theme", nextTheme);

		if (nextTheme === "dark") {
			document.documentElement.classList.add("dark");
		} else {
			document.documentElement.classList.remove("dark");
		}

		document.cookie = `theme=${nextTheme}; path=/; max-age=31536000; SameSite=Lax`;
	}
}
