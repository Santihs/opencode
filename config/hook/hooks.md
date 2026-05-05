---
hooks:
  - event: tool.before.bash
    actions:
      - bash: $HOOK_VALIDATE_BASH
      - bash: $HOOK_LOG_COMMANDS

  - event: tool.before.write
    actions:
      - bash: $HOOK_PROTECT_FILES
      - bash: $HOOK_LOG_FILE_CHANGES

  - event: tool.before.edit
    actions:
      - bash: $HOOK_PROTECT_FILES
      - bash: $HOOK_LOG_FILE_CHANGES
---
