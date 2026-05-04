export interface ApiEnvelope<T> {
  status: boolean;
  code: number;
  message: string;
  data: T;
}

export function ok<T>(data: T, message = "نجاح", code = 200): ApiEnvelope<T> {
  return {
    status: true,
    code,
    message,
    data,
  };
}

export function unwrapData<T extends object>(body: unknown): T {
  if (body && typeof body === "object" && "data" in body) {
    return (body as { data: T }).data;
  }
  return body as T;
}
