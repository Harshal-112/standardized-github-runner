const fs = require("node:fs");
const path = require("node:path");
const { getServiceStatus } = require("../src/app");

const outputDirectory = path.join(__dirname, "..", "dist");

fs.mkdirSync(outputDirectory, { recursive: true });

fs.writeFileSync(
  path.join(outputDirectory, "status.json"),
  JSON.stringify(getServiceStatus(), null, 2)
);

console.log("Build completed successfully.");
