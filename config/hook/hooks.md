---
hooks:
  - event: tool.before.bash
    actions:
      - bash: $OPENCODE_CONFIG_DIR/hooks/validate-bash.sh
      - bash: node $OPENCODE_CONFIG_DIR/hooks/log-commands.js

  - event: tool.before.write
    actions:
      - bash: $OPENCODE_CONFIG_DIR/hooks/protect-sensitive-files.sh
      - bash: node $OPENCODE_CONFIG_DIR/hooks/log-file-changes.js

  - event: tool.before.edit
    actions:
      - bash: $OPENCODE_CONFIG_DIR/hooks/protect-sensitive-files.sh
      - bash: node $OPENCODE_CONFIG_DIR/hooks/log-file-changes.js
---
