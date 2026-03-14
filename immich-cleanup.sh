#!/bin/sh
# /usr/local/bin/immich-cleanup.sh

PORTAINER_URL="http://192.168.1.17:8100/api"
STACK_ID=1  # Immich Stack ID
ENDPOINT_ID=3  # Portainer에서 확인 가능 (보통 1)
TOKEN="ptr_AGYW0DJkvFx5qvLQ9EZ3w7IdxBFqdUBp0rsI3GLWqos="

LOG() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 재시도 함수
retry() {
  CMD=$1
  DESCRIPTION=$2
  MAX_RETRIES=5
  DELAY=10

  COUNT=1
  while [ $COUNT -le $MAX_RETRIES ]; do
    LOG "$DESCRIPTION (시도 $COUNT/$MAX_RETRIES)"
    
    # 명령 실행 후 결과 저장
    RESPONSE=$(eval "$CMD" 2>&1)
    STATUS=$?

    echo "$RESPONSE"

    # 성공 판단: exit code == 0 AND 응답에 'Unable' 같은 오류 문구 없음
    echo "$RESPONSE" | grep -qi "unable\|error\|fail"
    HAS_ERROR=$?

    if [ $STATUS -eq 0 ] && [ $HAS_ERROR -ne 0 ]; then
      LOG "$DESCRIPTION 성공"
      return 0
    fi

    LOG "$DESCRIPTION 실패 → ${DELAY}s 후 재시도"
    sleep $DELAY
    COUNT=$((COUNT + 1))
  done

  LOG "$DESCRIPTION 재시도 실패(모든 시도 소진)"
  return 1
}


LOG "Immich cleanup started."


# 1) 스택 중지
retry \
  "curl -s -X POST -H \"X-API-Key:$TOKEN\" \"$PORTAINER_URL/stacks/$STACK_ID/stop?endpointId=$ENDPOINT_ID\"" \
  "Immich stack 정지"


# 2) Docker system prune
LOG "Running docker system prune..."
docker system prune -af


# 3) 스택 재시작 **재시도 포함**
retry \
  "curl -s -X POST -H \"X-API-Key:$TOKEN\" \"$PORTAINER_URL/stacks/$STACK_ID/start?endpointId=$ENDPOINT_ID\"" \
  "Immich stack 재시작"


# 4) dangling volumes 제거(immich 외 서비스가 추가되는 경우 정리 필요)
LOG "Removing dangling volumes..."
docker volume prune -f

LOG "Immich cleanup finished."
