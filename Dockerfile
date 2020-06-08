FROM swift:5.2 as builder
LABEL maintainer="Akii MEL <dev@akii.me>"
LABEL Description="Docker Container for Akii's Website."

WORKDIR /build

COPY . .

RUN swift build --enable-test-discovery -c release -Xswiftc -g \
    && mv `swift build -c release --show-bin-path` /build/bin


# Production image
FROM swift:5.2-slim

WORKDIR /app

ARG APP_SERVE_MODE=production
ARG APP_SERVE_PORT=8080

ENV APP_SERVE_MODE=$APP_SERVE_MODE \
    APP_SERVE_PORT=$APP_SERVE_PORT

COPY --from=builder /build/bin/Run .
COPY --from=builder /build/Public ./Public

ENTRYPOINT ./Run serve --env $APP_SERVE_MODE --hostname 0.0.0.0 --port $APP_SERVE_PORT