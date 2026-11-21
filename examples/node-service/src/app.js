function getServiceStatus() {
  return {
    service: "runner-node-service",
    status: "healthy"
  };
}

module.exports = { getServiceStatus };
