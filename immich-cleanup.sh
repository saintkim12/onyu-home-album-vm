#!/bin/bash
# /usr/local/bin/immich-cleanup.sh

PORTAINER_URL="http://192.168.1.17:8100/api"
STACK_ID=1  # Immich Stack ID
ENDPOINT_ID=3  # Portainer에서 확인 가능 (보통 1)

set -e
LOGTIME=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$LOGTIME] Immich cleanup started."

# 1️⃣ 로그인 (JWT 토큰 획득)
TOKEN="ptr_AGYW0DJkvFx5qvLQ9EZ3w7IdxBFqdUBp0rsI3GLWqos="

# 2️⃣ 스택 중지
LOGTIME=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$LOGTIME] Stopping Immich stack..."
curl -X POST \
  -H "X-API-Key:$TOKEN" \
  "$PORTAINER_URL/stacks/$STACK_ID/stop?endpointId=$ENDPOINT_ID"
echo ""

# 3️⃣ 시스템 정리
LOGTIME=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$LOGTIME] Running docker system prune..."
docker system prune -af

# 4️⃣ 스택 재시작
LOGTIME=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$LOGTIME] Restarting Immich stack..."
curl -X POST \
  -H "X-API-Key:$TOKEN" \
  "$PORTAINER_URL/stacks/$STACK_ID/start?endpointId=$ENDPOINT_ID"
echo ""

LOGTIME=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$LOGTIME] Immich cleanup finished."
