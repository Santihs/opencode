---
hooks:
  - event: tool.before.bash
    actions:
      - bash: $HOOK_BEFORE_BASH

  - event: tool.before.write
    actions:
      - bash: $HOOK_BEFORE_FILE

  - event: tool.before.edit
    actions:
      - bash: $HOOK_BEFORE_FILE
---
