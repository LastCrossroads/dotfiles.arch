#!/usr/bin/env bash

# Use canonical path instead of convenience symlink:
INBOX=/var/spool/mail/$USER/

# If inbox does not exist...
if [ ! -d $INBOX ]; then
  # ... hide widget.
  exec sleep infinity
fi

render() {
  # Ignore errors here to avoid spamming logs.
  COUNT=$(find $INBOX -type f 2> /dev/null | wc -l)
  if [ $COUNT -ne 0 ]; then
    echo "$COUNT"
  else
    # printf '{"text": "0", "alt": "0", "tooltip": "Mailbox empty", "class": "green"}'
    echo "0"
  fi
}

while true; do
  render
  inotifywait \
    --event create \
    --event delete \
    --event moved_to \
    --event move \
    --monitor \
    "$INBOX" 2> /dev/null | \
    while read -r _; do
      sleep 0.1 # Throttle; this doesn't need more than 10fps.
      render
    done
done
