import { ValidationPipe } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { NestFactory } from "@nestjs/core";
import { NestExpressApplication } from "@nestjs/platform-express";
import { DocumentBuilder, SwaggerModule } from "@nestjs/swagger";
import helmet from "helmet";
import { join } from "node:path";

import { AppModule } from "./app.module";

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  const config = app.get(ConfigService);
  const apiPrefix = config.get<string>("API_PREFIX", "api/v1");

  app.useStaticAssets(join(process.cwd(), "public"));
  app.setGlobalPrefix(apiPrefix);
  app.enableCors({
    origin: corsOrigins(config),
    credentials: true,
  });
  app.use(helmet());
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  if (config.get<string>("NODE_ENV", "development") !== "production") {
    const swaggerConfig = new DocumentBuilder()
      .setTitle("Al Shihab Local API")
      .setDescription("Local NestJS API for Flutter auth integration")
      .setVersion("0.1.0")
      .addBearerAuth()
      .addApiKey(
        { type: "apiKey", name: "X-API-APP-KEY", in: "header" },
        "AppKeyAuth",
      )
      .addApiKey(
        { type: "apiKey", name: "X-API-APP-SECRET", in: "header" },
        "AppSecretAuth",
      )
      .build();
    const document = SwaggerModule.createDocument(app, swaggerConfig);
    SwaggerModule.setup("docs", app, document, {
      swaggerOptions: { persistAuthorization: true },
    });
  }

  const port = config.get<number>("PORT", 3000);
  await app.listen(port);
  // eslint-disable-next-line no-console
  console.log(`Local API: http://localhost:${port}/${apiPrefix}`);
  if (config.get<string>("NODE_ENV", "development") !== "production") {
    // eslint-disable-next-line no-console
    console.log(`Swagger:   http://localhost:${port}/docs`);
  }
}

void bootstrap();

function corsOrigins(config: ConfigService) {
  const raw = config.get<string>("CORS_ORIGINS", "");
  const origins = raw
    .split(",")
    .map((origin) => origin.trim())
    .filter(Boolean);

  if (origins.length > 0) return origins;
  return config.get<string>("NODE_ENV", "development") === "production"
    ? false
    : true;
}
