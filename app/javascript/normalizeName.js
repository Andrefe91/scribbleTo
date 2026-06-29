export default function normalizeName(name) {
	return String(name)
		.toLowerCase()
		.trimStart()
		.replace(/\s+(?=\S)/g, "-")
		.replace(/[^a-z0-9- ]/g, "");
}
