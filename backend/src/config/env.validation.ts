type Env = Record<string, string | undefined>;

const weakSecrets = new Set([
  "local-secret",
  "change-this-local-secret-before-sharing",
  "change-this-refresh-secret-before-sharing",
]);

export function validateEnv(config: Env) {
  const nodeEnv = config.NODE_ENV ?? "development";
  const isProduction = nodeEnv === "production";

  requireValue(config, "JWT_SECRET");
  requireValue(config, "JWT_REFRESH_SECRET");

  if (isProduction) {
    requireStrongSecret(config, "JWT_SECRET");
    requireStrongSecret(config, "JWT_REFRESH_SECRET");
    requireValue(config, "APP_KEY");
    requireValue(config, "APP_SECRET");
    requireStrongSecret(config, "ADMIN_KEY");
  }

  if (
    config.JWT_SECRET &&
    config.JWT_REFRESH_SECRET &&
    config.JWT_SECRET === config.JWT_REFRESH_SECRET
  ) {
    throw new Error("JWT_SECRET and JWT_REFRESH_SECRET must be different");
  }

  return config;
}

function requireValue(config: Env, key: string) {
  if (!config[key]) {
    throw new Error(`${key} is required`);
  }
}

function requireStrongSecret(config: Env, key: string) {
  const value = config[key];
  requireValue(config, key);

  if (!value || value.length < 32 || weakSecrets.has(value)) {
    throw new Error(`${key} must be a strong secret in production`);
  }
}
