# Safe Commit Plan

## Inspection Summary
- **Branch**: main (up to date with origin/main)
- **Modified files**: 5
- **Untracked files**: 4
- **Total changes**: 55 insertions(+), 22 deletions(-)

## Safety Check Results
✅ No secrets, keys, or credentials detected in changes
✅ No .env or sensitive configuration files staged
✅ All changes appear to be hook implementation updates

## File Analysis
### Modified Files:
1. `config/hook/hooks.md` - Hook configuration updates
2. `config/hooks/log-commands.js` - JavaScript hook implementation (partial removal)
3. `config/hooks/log-file-changes.js` - JavaScript hook implementation (partial removal)
4. `config/opencode.json` - Configuration updates (likely plugin/format changes)
5. `update.ps1` - PowerShell update script enhancements

### New Files (Untracked):
1. `config/hooks/log-commands.ps1` - PowerShell version of log-commands hook
2. `config/hooks/log-file-changes.ps1` - PowerShell version of log-file-changes hook
3. `config/hooks/protect-sensitive-files.ps1` - PowerShell sensitive file protection hook
4. `config/hooks/validate-bash.ps1` - PowerShell bash validation hook

## Proposed Commit Groups

### Commit 1: Hook Infrastructure Updates
**Description**: Update hook configuration and add PowerShell implementations
**Files**:
- config/hook/hooks.md
- config/hooks/log-commands.ps1
- config/hooks/log-file-changes.ps1
- config/hooks/protect-sensitive-files.ps1
- config/hooks/validate-bash.ps1

### Commit 2: JavaScript Hook Cleanup
**Description**: Remove/update JavaScript hook implementations being replaced by PowerShell versions
**Files**:
- config/hooks/log-commands.js
- config/hooks/log-file-changes.js

### Commit 3: Configuration and Update Script Enhancements
**Description**: Update main configuration and improve update script
**Files**:
- config/opencode.json
- update.ps1

## Copy-Paste Commands for Execution

### To inspect before committing:
```bash
git status
git diff --stat
```

### To execute the commit plan:
```bash
# Commit 1: Hook Infrastructure Updates
git add config/hook/hooks.md config/hooks/log-commands.ps1 config/hooks/log-file-changes.ps1 config/hooks/protect-sensitive-files.ps1 config/hooks/validate-bash.ps1
git commit -m "chore(hooks): add PowerShell implementations and update hook configuration"

# Commit 2: JavaScript Hook Cleanup
git add config/hooks/log-commands.js config/hooks/log-file-changes.js
git commit -m "chore(hooks): remove JavaScript hook implementations replaced by PowerShell versions"

# Commit 3: Configuration and Update Script Enhancements
git add config/opencode.json update.ps1
git commit -m "chore(config): update opencode configuration and enhance update script"
```

## Notes
- All commits follow conventional commit format (type(scope): description)
- No force operations or history rewriting involved
- Each commit represents a logical group of related changes
- Safety checks completed before proposing commits