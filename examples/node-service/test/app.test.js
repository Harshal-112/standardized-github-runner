const test = require("node:test");
const assert = require("node:assert/strict");
const { getServiceStatus } = require("../src/app");

test("service returns a healthy status", () => {
  const result = getServiceStatus();

  assert.equal(result.service, "runner-node-service");
  assert.equal(result.status, "healthy");
});
