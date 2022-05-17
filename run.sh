#!/bin/sh

XRAY_VERSION=v1.5.5

apk add --no-cache unzip wget
wget "https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip" -O /tmp/Xray-linux-64.zip
wget "https://github.com/v2fly/geoip/releases/latest/download/geoip.dat" -O /tmp/geoip.dat
wget "https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat" -O /tmp/dlc.dat

mkdir /usr/local/share/xray
mkdir /usr/local/etc/xray
mkdir /var/log/xray

unzip /tmp/Xray-linux-64.zip -d /tmp
install -m 0755 /tmp/xray /usr/local/bin/xray
install -m 0644 /tmp/geoip.dat /usr/share/xray/geoip.dat
install -m 0644 /tmp/dlc.dat /usr/share/xray/geosite.dat

cat > /usr/local/etc/xray/config.json <<EOF
{
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "port": "$PORT",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "$UUID"
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "acceptProxyProtocol": true,
                    "path": "/"
                }
            }
        }
    ],
    "outbounds": [
        {
            "tag": "direct",
            "protocol": "freedom",
            "settings": {}
        },
        {
            "tag": "blocked",
            "protocol": "blackhole",
            "settings": {}
        }
    ],
    "routing": {
        "domainStrategy": "AsIs",
        "rules": [
            {
                "type": "field",
                "ip": [
                    "geoip:private"
                ],
                "outboundTag": "blocked"
            },
            {
                "type": "field",
                "domain": [
                    "geosite:cn"
                ],
                "outboundTag": "blocked"
            },
            {
                "type": "field",
                "ip": [
                    "geoip:cn"
                ],
                "outboundTag": "blocked"
            }
        ]
    }
}
EOF

rm -rf /tmp/Xray-linux-64.zip /tmp/xray /tmp/geoip.dat /tmp/dlc.dat
