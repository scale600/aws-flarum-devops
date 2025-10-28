#!/bin/bash

# =============================================================================
# Watch RiderHub Site - Monitor until site is live
# =============================================================================

SITE_URL="http://riderhub-flarum-alb-1445300398.us-east-1.elb.amazonaws.com"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  🔄 Monitoring RiderHub Site${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}URL: $SITE_URL${NC}"
echo ""
echo -e "${YELLOW}Checking every 10 seconds... Press Ctrl+C to stop${NC}"
echo ""

ATTEMPT=1
START_TIME=$(date +%s)

while true; do
    CURRENT_TIME=$(date +%s)
    ELAPSED=$(( CURRENT_TIME - START_TIME ))
    MINUTES=$(( ELAPSED / 60 ))
    SECONDS=$(( ELAPSED % 60 ))
    
    printf "${CYAN}[%02d:%02d]${NC} Attempt %d: " $MINUTES $SECONDS $ATTEMPT
    
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$SITE_URL" 2>/dev/null)
    
    case "$HTTP_CODE" in
        200|302)
            echo -e "${GREEN}HTTP $HTTP_CODE - SUCCESS!${NC}"
            echo ""
            echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║                                                            ║${NC}"
            echo -e "${GREEN}║              🎉 YOUR SITE IS LIVE! 🎉                      ║${NC}"
            echo -e "${GREEN}║                                                            ║${NC}"
            echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
            echo ""
            echo -e "${CYAN}Visit your forum:${NC}"
            echo -e "   ${BLUE}$SITE_URL${NC}"
            echo ""
            echo -e "${CYAN}Total time:${NC} $MINUTES minutes $SECONDS seconds"
            echo ""
            
            # Try to open in browser
            if [[ "$OSTYPE" == "darwin"* ]]; then
                echo -e "${YELLOW}Opening in browser...${NC}"
                open "$SITE_URL"
            elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                xdg-open "$SITE_URL"
            fi
            
            exit 0
            ;;
        503)
            echo -e "${YELLOW}HTTP 503${NC} - Still installing..."
            ;;
        502)
            echo -e "${YELLOW}HTTP 502${NC} - Service starting..."
            ;;
        000)
            echo -e "${RED}HTTP 000${NC} - Connection failed"
            ;;
        *)
            echo -e "${YELLOW}HTTP $HTTP_CODE${NC} - Unexpected response"
            ;;
    esac
    
    ATTEMPT=$((ATTEMPT + 1))
    sleep 10
done

