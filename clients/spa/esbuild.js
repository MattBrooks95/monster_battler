import esbuild from "esbuild"
import sveltePlugin from "esbuild-svelte"

esbuild.build({
	entryPoints: ["src/main.js"],
	mainFields: ["svelte", "browser", "module", "main"],
	bundle: true,
	outfile: "build/spa.js",
	plugins: [sveltePlugin()],
	logLevel: "info",
}).catch(() => process.exit(1));
