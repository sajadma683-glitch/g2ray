#!/bin/bash
set -e

echo "🚀 Starting G2Ray optimized setup..."

# نصب وابستگی‌ها
apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl unzip uuid-runtime tzdata \
    && rm -rf /var/lib/apt/lists/*

# دانلود Xray (نسخه جدیدتر)
XRAY_VERSION="v1.8.24"  # یا جدیدترین نسخه
curl -L -o /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip"
unzip -o /tmp/xray.zip -d /usr/local/bin/
chmod +x /usr/local/bin/xray
rm /tmp/xray.zip

# ایجاد UUID و SNI جدید
UUID=$(uuidgen)
CODESPACE_NAME=${CODESPACE_NAME:-$(hostname)}
SNI="${CODESPACE_NAME}.github.dev"

echo "🔑 Generated UUID: ${UUID}"
echo "🌐 SNI: ${SNI}"

# ایجاد config از template
cat > /etc/xray/config.json << EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [{
    "port": 443,
    "protocol": "vless",
    "settings": {
      "clients": [{
        "id": "${UUID}",
        "flow": "xtls-rprx-vision"
      }],
      "decryption": "none"
    },
    "streamSettings": {
      "network": "tcp",
      "security": "tls",
      "tlsSettings": {
        "serverName": "${SNI}",
        "alpn": ["h2", "http/1.1"]
      }
    }
  }],
  "outbounds": [{
    "protocol": "freedom"
  }]
}
EOF

mkdir -p /var/log/xray

echo "✅ Setup completed!"
echo ""
echo "🔗 Your VLESS Link:"
echo "vless://${UUID}@${SNI}:443?security=tls&flow=xtls-rprx-vision&fp=chrome&type=tcp&headerType=none#G2Ray-${CODESPACE_NAME}"
echo ""
echo "📌 Import this link in V2RayNG, Nekobox, or Clash Meta"
echo "⛔ Don't forget to STOP the Codespace when not in use!"

# اجرای Xray
exec /usr/local/bin/xray run -c /etc/xray/config.json
