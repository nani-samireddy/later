import { defineConfig } from "vite";
// BASE_PATH is supplied by CI; local previews intentionally use the project URL.
export default defineConfig({
  base: process.env.BASE_PATH || "/later/",
  build: {
    rollupOptions: {
      onwarn(warning, warn) {
        // These libraries mark client components for server renderers; this is a client-only site.
        if (
          warning.code === "MODULE_LEVEL_DIRECTIVE" &&
          warning.message.includes("use client")
        )
          return;
        warn(warning);
      },
      input: {
        home: "index.html",
        privacy: "privacy-policy/index.html",
        terms: "terms-and-conditions/index.html",
      },
    },
  },
});
