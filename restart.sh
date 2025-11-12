#!/bin/sh
YOUR_SERVER_IP='<your-server-ip>'
ALBUM_VM_DIR=/opt/setup/album-vm
export PORTAINER_PORT=8100
echo "🔁 Restarting Docker + Portainer..."

service docker restart

cd "$ALBUM_VM_DIR/portainer"
docker-compose down
docker-compose up -d

echo "✅ Portainer restarted on :$PORTAINER_PORT"
echo "👉 Access at: http://$YOUR_SERVER_IP:$PORTAINER_PORT"
