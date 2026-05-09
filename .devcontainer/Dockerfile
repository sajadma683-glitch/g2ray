FROM mcr.microsoft.com/devcontainers/base:bookworm

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl unzip uuid-runtime \
    && rm -rf /var/lib/apt/lists/* \
    && curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v1.8.24/Xray-linux-64.zip \
    && unzip /tmp/xray.zip -d /usr/local/bin/ \
    && chmod +x /usr/local/bin/xray \
    && rm /tmp/xray.zip

COPY .devcontainer/setup.sh /setup.sh
RUN chmod +x /setup.sh

CMD ["/setup.sh"]
