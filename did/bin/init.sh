#!/bin/bash
set -euo pipefail

EXPIRE_SECONDS=60

echo "⚠️  THIS KEY WILL BE SHOWN ONLY ONCE"
echo "⚠️  COPY IT NOW. IT WILL BE DESTROYED AFTER ${EXPIRE_SECONDS}s"
echo ""

########################################
# MEMORY ONLY KEY GENERATION
########################################

PRIVATE_KEY=$(openssl genpkey -algorithm ed25519)
PUBLIC_KEY=$(echo "$PRIVATE_KEY" | openssl pkey -pubout)

PRIVATE_B64=$(echo "$PRIVATE_KEY" | base64 | tr -d '\n')
PUBLIC_B64=$(echo "$PUBLIC_KEY" | base64 | tr -d '\n')

unset PRIVATE_KEY
unset PUBLIC_KEY

########################################
# DISPLAY
########################################

echo "================ PRIVATE KEY ================"
echo "$PRIVATE_B64"
echo "============================================="
echo ""

echo "================ PUBLIC KEY ================"
echo "$PUBLIC_B64"
echo "============================================="
echo ""

echo "⏳ This session will self-destruct in ${EXPIRE_SECONDS}s"

########################################
# AUTO CLEAR SCREEN
########################################

(
  sleep "$EXPIRE_SECONDS"
  clear
  echo "❌ KEY SESSION EXPIRED"
  echo "❌ NOTHING WAS STORED"
) &
