#!/bin/bash
# 스크린샷을 docs/screenshots, docs/gifs 에 넣은 뒤 실행하면 PDF를 다시 생성함
set -e
cd "$(dirname "$0")"
CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

for LANG in ko en; do
  "$CHROME" --headless --disable-gpu --no-pdf-header-footer \
            --virtual-time-budget=8000 \
            --print-to-pdf="portfolio-$LANG.pdf" \
            "file://$PWD/portfolio-$LANG.html"
  echo "✓ portfolio-$LANG.pdf"
done
