// Runtime environment configuration template
// This file is used by docker-entrypoint.sh to inject environment variables at runtime

window.ENV = {
  REACT_APP_BACKEND_URL: "${REACT_APP_BACKEND_URL}",
  NODE_ENV: "${NODE_ENV}"
};