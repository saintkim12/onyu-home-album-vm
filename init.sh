#!/bin/sh
set -e

GIT_USER=saintkim12
GIT_REPO=onyu-home-album-vm
GIT_BRANCH=main
GIT_URL=https://github.com/${GIT_USER}/${GIT_REPO}.git
MAIN_VM_DIR=/opt/setup/album-vm
YOUR_SERVER_IP='<your-server-ip>'

mkdir -p /opt/setup
cd /opt/setup

### [1] Alpine 패키지 및 Docker, rclone 설치
echo "📦 Installing Docker..."
apk update
apk add --no-cache docker docker-compose git curl openrc rclone fuse3

# ### [2] rclone.conf 생성
# CONFIG_DIR="$HOME/.config/rclone"
# CONFIG_FILE="$CONFIG_DIR/rclone.conf"

# # ~/.config/rclone 디렉토리가 없으면 생성
# if [ ! -d "$CONFIG_DIR" ]; then
#     echo "Creating directory $CONFIG_DIR..."
#     mkdir -p "$CONFIG_DIR"
# fi

# # rclone.conf 파일이 없으면 생성
# if [ ! -f "$CONFIG_FILE" ]; then
#     echo "Creating rclone config file $CONFIG_FILE..."
#     cat <<EOF > "$CONFIG_FILE"
# # ~/.config/rclone/rclone.conf
# # see http://192.168.1.15:9001/access-keys
# [immich-s3]
# type = s3
# provider = Minio
# access_key_id = QSvk6zEHUuTNPtdJ9IN0
# secret_access_key = KDbURVPqGaPAISn96vMQYUI5rQXVgEJLawCYY3gW
# endpoint = http://192.168.1.15:9000
# acl = private
# EOF
#     echo "rclone.conf has been created."
# else
#     echo "$CONFIG_FILE already exists. Skipping creation."
# fi

# ### [3] immich-s3 마운트
# MOUNT_POINT="/mnt/immich-s3"
# # mount point 없으면 생성
# [ ! -d "$MOUNT_POINT" ] && mkdir -p "$MOUNT_POINT"



echo "🔌 Enabling docker service..."
rc-update add docker boot
service docker start

echo "📥 Cloning Git repository..."

### [2] Git 저장소 클론
if [ ! -d "$MAIN_VM_DIR" ]; then
  git clone -b "$GIT_BRANCH" "$GIT_URL" "$MAIN_VM_DIR"
else
  echo "📦 Repo exists, pulling latest..."
  cd "$MAIN_VM_DIR" && git pull && cd ..
fi

### [3] 메인 디렉토리로 이동
cd "$MAIN_VM_DIR"

### [4] Portainer Docker 컨테이너 실행
echo "🚀 Starting Portainer..."
cd portainer
export PORTAINER_PORT=8100
docker-compose up -d

echo "✅ Portainer started on :$PORTAINER_PORT"
echo "👉 Access at: http://$YOUR_SERVER_IP:$PORTAINER_PORT"

echo ""
echo "📝 Next Step:"
echo "1. Open Portainer UI"
echo "2. Set Stack and Run Container"

