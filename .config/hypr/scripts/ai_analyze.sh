#!/bin/bash

# ================================================
# Hyprland AI Assistant
# ================================================
# A smart AI assistant for Hyprland/Wayland that provides:
# - OCR text extraction and analysis
# - Image analysis with AI vision
# - Quick explanations for selected text
#
# Powered by Google Gemini API
#
# DEPENDENCIES:
# - grim, slurp (screenshot tools)
# - tesseract (OCR)
# - jq (JSON parsing)
# - wl-clipboard (clipboard access)
# - zenity (GUI dialogs)
# - curl (API requests)
# - imagemagick (image compression)
#
# INSTALLATION:
# 1. Install dependencies:
#    sudo pacman -S grim slurp tesseract jq wl-clipboard zenity curl imagemagick
#
# 2. Get a Gemini API key:
#    https://makersuite.google.com/app/apikey
#
# 3. Add your API key to the script (line ~30)
#
# 4. Make executable:
#    chmod +x hyprland-ai-assistant.sh
#
# 5. (Optional) Bind to a keybind in Hyprland config:
#    bind = $mainMod, A, exec, /path/to/hyprland-ai-assistant.sh
#
# USAGE:
# Run the script, choose your mode, and let AI do the work!
# ================================================

# TODO: Add your Gemini API key here
API_KEY="AIzaSyDOQPYwX7OUQiuH_2HFvXxZo-T7AC1OAJw"

API_URL_TEXT="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${API_KEY}"
API_URL_VISION="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${API_KEY}"

TEMP_IMG="/tmp/ai_query.png"
TEMP_RESPONSE="/tmp/ai_response.txt"

# Check if API key is set
if [ -z "$API_KEY" ]; then
    notify-send "AI Assistant" "Error: API_KEY is not set! Edit the script and add your Gemini API key." -u critical
    exit 1
fi

# Check for required dependencies
MISSING_DEPS=()

command -v grim &> /dev/null || MISSING_DEPS+=("grim")
command -v slurp &> /dev/null || MISSING_DEPS+=("slurp")
command -v tesseract &> /dev/null || MISSING_DEPS+=("tesseract")
command -v jq &> /dev/null || MISSING_DEPS+=("jq")
command -v wl-paste &> /dev/null || MISSING_DEPS+=("wl-clipboard")
command -v wl-copy &> /dev/null || MISSING_DEPS+=("wl-clipboard")
command -v zenity &> /dev/null || MISSING_DEPS+=("zenity")
command -v curl &> /dev/null || MISSING_DEPS+=("curl")
command -v base64 &> /dev/null || MISSING_DEPS+=("base64")
command -v convert &> /dev/null || MISSING_DEPS+=("imagemagick")

if [ ${#MISSING_DEPS[@]} -ne 0 ]; then
    DEPS_LIST=$(printf ", %s" "${MISSING_DEPS[@]}")
    DEPS_LIST=${DEPS_LIST:2}
    notify-send "AI Assistant" "Missing dependencies: ${DEPS_LIST}\n\nInstall with: sudo pacman -S ${DEPS_LIST}" -u critical
    exit 1
fi

# Show the menu first
if command -v zenity &> /dev/null; then
    CHOICE=$(zenity --list \
        --title="AI Assistant" \
        --text="What do you want to do?" \
        --column="Option" \
        "1. OCR Text (Screenshot → Extract & Analyze)" \
        "2. Image Analysis (Screenshot → AI Vision)" \
        "3. Explain Selected Text (From Clipboard)" \
        --width=500 --height=300)
else
    notify-send "AI Assistant" "zenity not found, defaulting to OCR..." -t 2000
    CHOICE="1. OCR Text (Screenshot → Extract & Analyze)"
fi

# User cancelled
if [ -z "$CHOICE" ] || echo "$CHOICE" | grep -q "Cancel"; then
    notify-send "AI Assistant" "Cancelled" -u low
    exit 0
fi

# Handle clipboard text mode
if echo "$CHOICE" | grep -q "Explain Selected Text"; then
    notify-send "AI Assistant" "Getting clipboard text..." -t 1000
    
    QUERY=$(wl-paste 2>/dev/null)
    
    if [ -z "$QUERY" ]; then
        notify-send "AI Assistant" "Nothing in clipboard! Select some text first." -u critical
        exit 1
    fi
    
    # cleanup whitespace
    QUERY=$(echo "$QUERY" | tr -s ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    WORD_COUNT=$(echo "$QUERY" | wc -w)
    
    # figure out what kind of query this is
    PROMPT_SUFFIX=" Respond in plain text only, no markdown, no formatting, no asterisks or special characters. Just give me the facts."
    
    if [ $WORD_COUNT -eq 1 ]; then
        PROMPT="Define \"$QUERY\" - include part of speech and an example.${PROMPT_SUFFIX}"
    elif [ $WORD_COUNT -le 3 ]; then
        PROMPT="What does \"$QUERY\" mean?${PROMPT_SUFFIX}"
    elif echo "$QUERY" | grep -qiE "error|exception|traceback|failed|warning"; then
        PROMPT="Explain this error and how to fix it:\n\n$QUERY\n\n${PROMPT_SUFFIX}"
    elif echo "$QUERY" | grep -qE "^(def|function|class|import|const|let|var|public|private|int|void|\{|\})"; then
        PROMPT="Give the output first, then explain this code:\n\n$QUERY\n\n${PROMPT_SUFFIX}"
    elif echo "$QUERY" | grep -qE "\?$"; then
        PROMPT="$QUERY\n\n${PROMPT_SUFFIX}"
    else
        PROMPT="$QUERY\n\n${PROMPT_SUFFIX}"
    fi
    
    notify-send "AI Assistant" "Processing..." -t 2000
    
    JSON_PAYLOAD=$(jq -n \
        --arg prompt "$PROMPT" \
        '{
            contents: [{
                parts: [{
                    text: $prompt
                }]
            }]
        }')
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL_TEXT" \
        -H "Content-Type: application/json" \
        -d "$JSON_PAYLOAD")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    RESPONSE=$(echo "$RESPONSE" | head -n-1)
    
    if [ "$HTTP_CODE" != "200" ]; then
        notify-send "AI Assistant" "API Error (HTTP $HTTP_CODE)\nCheck your API key or quota" -u critical
        echo "HTTP Error: $HTTP_CODE" >> /tmp/ai_debug.log
        echo "$RESPONSE" >> /tmp/ai_debug.log
        exit 1
    fi

# OCR mode - grab screenshot and extract text
elif echo "$CHOICE" | grep -q "OCR"; then
    grim -g "$(slurp)" "$TEMP_IMG" 2>/dev/null || {
        notify-send "AI Assistant" "Screenshot cancelled" -u low
        exit 1
    }
    
    QUERY=$(tesseract "$TEMP_IMG" - -l eng 2>/dev/null)
    
    if [ -z "$QUERY" ]; then
        notify-send "AI Assistant" "Couldn't find any text!" -u critical
        rm -f "$TEMP_IMG"
        exit 1
    fi
    
    QUERY=$(echo "$QUERY" | tr -s ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    
    WORD_COUNT=$(echo "$QUERY" | wc -w)
    
    PROMPT_SUFFIX=" Respond in plain text only, no markdown, no formatting, no asterisks or special characters. Just give me the facts."
    
    # decide how to prompt based on what we found
    if [ $WORD_COUNT -eq 1 ]; then
        PROMPT="Define \"$QUERY\" - include part of speech and an example.${PROMPT_SUFFIX}"
    elif [ $WORD_COUNT -le 3 ]; then
        PROMPT="What does \"$QUERY\" mean?${PROMPT_SUFFIX}"
    elif echo "$QUERY" | grep -qiE "error|exception|traceback|failed|warning"; then
        PROMPT="Explain this error and how to fix it:\n\n$QUERY\n\n${PROMPT_SUFFIX}"
    elif echo "$QUERY" | grep -qE "^(def|function|class|import|const|let|var|public|private|int|void|\{|\})"; then
        PROMPT="Give the output first, then explain this code:\n\n$QUERY\n\n${PROMPT_SUFFIX}"
    elif echo "$QUERY" | grep -qE "\?$"; then
        PROMPT="$QUERY\n\n${PROMPT_SUFFIX}"
    else
        PROMPT="$QUERY\n\n${PROMPT_SUFFIX}"
    fi
    
    notify-send "AI Assistant" "Processing text..." -t 2000
    
    JSON_PAYLOAD=$(jq -n \
        --arg prompt "$PROMPT" \
        '{
            contents: [{
                parts: [{
                    text: $prompt
                }]
            }]
        }')
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL_TEXT" \
        -H "Content-Type: application/json" \
        -d "$JSON_PAYLOAD")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    RESPONSE=$(echo "$RESPONSE" | head -n-1)
    
    if [ "$HTTP_CODE" != "200" ]; then
        notify-send "AI Assistant" "API Error (HTTP $HTTP_CODE)\nCheck your API key or quota" -u critical
        echo "HTTP Error: $HTTP_CODE" >> /tmp/ai_debug.log
        echo "$RESPONSE" >> /tmp/ai_debug.log
        rm -f "$TEMP_IMG"
        exit 1
    fi
    
    rm -f "$TEMP_IMG"

# Image analysis mode
else
    grim -g "$(slurp)" "$TEMP_IMG" 2>/dev/null || {
        notify-send "AI Assistant" "Screenshot cancelled" -u low
        exit 1
    }
    
    notify-send "AI Assistant" "Analyzing image..." -t 2000
    
    # Compress image before sending to API (saves tokens/cost)
    TEMP_COMPRESSED="/tmp/ai_query_compressed.jpg"
    convert "$TEMP_IMG" -resize 1280x1280\> -quality 85 "$TEMP_COMPRESSED"
    
    # Use compressed image if conversion succeeded
    if [ -f "$TEMP_COMPRESSED" ]; then
        IMAGE_FILE="$TEMP_COMPRESSED"
    else
        IMAGE_FILE="$TEMP_IMG"
    fi
    
    IMAGE_BASE64=$(base64 -w 0 "$IMAGE_FILE")
    MIME_TYPE=$(file --mime-type -b "$IMAGE_FILE")
    
    # ask for optional instructions
    if command -v zenity &> /dev/null; then
        USER_PROMPT=$(zenity --entry \
            --title="AI Assistant - Image Analysis" \
            --text="Any specific instructions? (optional)" \
            --width=500)
    else
        USER_PROMPT=""
    fi
    
    if [ -z "$USER_PROMPT" ]; then
        USER_PROMPT="Analyze this image. Describe everything you see - text, objects, diagrams, whatever's there. If there's text, transcribe it. If it's a chart or diagram, explain it. Keep it plain text, no markdown."
    else
        USER_PROMPT="${USER_PROMPT} Keep response in plain text, no markdown."
    fi
    
    # debug stuff
    echo "Original image: $TEMP_IMG" > /tmp/ai_debug.log
    echo "Compressed image: $IMAGE_FILE" >> /tmp/ai_debug.log
    echo "Image size: ${#IMAGE_BASE64}" >> /tmp/ai_debug.log
    echo "MIME: $MIME_TYPE" >> /tmp/ai_debug.log
    echo "Prompt: $USER_PROMPT" >> /tmp/ai_debug.log
    
    TEMP_JSON="/tmp/ai_payload.json"
    cat > "$TEMP_JSON" <<EOF
{
  "contents": [
    {
      "parts": [
        {
          "text": "$USER_PROMPT"
        },
        {
          "inline_data": {
            "mime_type": "$MIME_TYPE",
            "data": "$IMAGE_BASE64"
          }
        }
      ]
    }
  ]
}
EOF
    
    echo "JSON payload: $(wc -c < "$TEMP_JSON") bytes" >> /tmp/ai_debug.log
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL_VISION" \
        -H "Content-Type: application/json" \
        -d "@$TEMP_JSON")
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    RESPONSE=$(echo "$RESPONSE" | head -n-1)
    
    if [ "$HTTP_CODE" != "200" ]; then
        notify-send "AI Assistant" "API Error (HTTP $HTTP_CODE)\nCheck your API key or quota" -u critical
        echo "HTTP Error: $HTTP_CODE" >> /tmp/ai_debug.log
        echo "$RESPONSE" >> /tmp/ai_debug.log
        rm -f "$TEMP_JSON"
        rm -f "$TEMP_IMG"
        exit 1
    fi
    
    rm -f "$TEMP_JSON"
    rm -f "$TEMP_IMG"
    
    QUERY="[Image Analysis]"
fi

# Parse response
echo "" >> /tmp/ai_debug.log
echo "Raw API response:" >> /tmp/ai_debug.log
echo "$RESPONSE" >> /tmp/ai_debug.log

AI_ANSWER=$(echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text' 2>/dev/null)

if [ -z "$AI_ANSWER" ] || [ "$AI_ANSWER" = "null" ]; then
    # Try to extract error message from API response
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error.message' 2>/dev/null)
    if [ -n "$ERROR_MSG" ] && [ "$ERROR_MSG" != "null" ]; then
        notify-send "AI Assistant" "API Error: $ERROR_MSG" -u critical
        echo "API Error: $ERROR_MSG" >> /tmp/ai_debug.log
    else
        notify-send "AI Assistant" "Failed to get response - check /tmp/ai_debug.log" -u critical
        echo "Error: couldn't extract answer" >> /tmp/ai_debug.log
    fi
    exit 1
fi

# save to file
echo "Query: $QUERY" > "$TEMP_RESPONSE"
echo "" >> "$TEMP_RESPONSE"
echo "$AI_ANSWER" >> "$TEMP_RESPONSE"

RESPONSE_LENGTH=${#AI_ANSWER}

# short answer -> notification, long answer -> zenity window
if [ $RESPONSE_LENGTH -lt 150 ]; then
    notify-send "AI Assistant" "$AI_ANSWER" -t 5000
else
    if command -v zenity &> /dev/null; then
        zenity --text-info \
            --title="AI Assistant" \
            --width=800 \
            --height=600 \
            --font="JetBrainsMonoNF-Regular 16" \
            --filename="$TEMP_RESPONSE" \
            --checkbox="Copy to clipboard"
        
        if [ $? -eq 0 ]; then
            if command -v wl-copy &> /dev/null; then
                cat "$TEMP_RESPONSE" | wl-copy
                notify-send "AI Assistant" "Copied to clipboard!" -t 2000
            else
                notify-send "AI Assistant" "wl-clipboard not installed (sudo pacman -S wl-clipboard)" -u normal
            fi
        fi
    elif command -v kitty &> /dev/null; then
        kitty -1 -e sh -c "cat '$TEMP_RESPONSE' | less -R" &
    else
        notify-send "AI Assistant" "Response saved to $TEMP_RESPONSE" -t 5000
    fi
fi

exit 0
