Describe "OpenCode agent orchestration configuration" {
    BeforeAll {
        function Get-AgentFrontmatterLines {
            param(
                [Parameter(Mandatory)]
                [string]$Content
            )

            $frontmatter = [regex]::Match(
                $Content,
                '\A---\r?\n(?<body>[\s\S]*?)\r?\n---(?:\r?\n|\z)'
            )

            if (-not $frontmatter.Success) {
                throw "Agent frontmatter must start and end with anchored --- markers."
            }

            @($frontmatter.Groups["body"].Value -split '\r?\n')
        }

        function Get-AgentBashPermissions {
            param(
                [Parameter(Mandatory)]
                [string]$Content
            )

            $lines = @(Get-AgentFrontmatterLines -Content $Content)
            $permissionIndexes = @(
                for ($index = 0; $index -lt $lines.Count; $index++) {
                    if ($lines[$index] -ceq "permission:") {
                        $index
                    }
                }
            )

            if ($permissionIndexes.Count -ne 1) {
                throw "Agent frontmatter must contain exactly one root permission block."
            }

            $permissionStart = [int]$permissionIndexes[0]
            $permissionEnd = $lines.Count
            for ($index = $permissionStart + 1; $index -lt $lines.Count; $index++) {
                if ($lines[$index] -match '^[^ \t]') {
                    $permissionEnd = $index
                    break
                }
            }

            $bashMapIndexes = @(
                for ($index = $permissionStart + 1; $index -lt $permissionEnd; $index++) {
                    if ($lines[$index] -ceq "  bash:") {
                        $index
                    }
                }
            )
            $bashLikeIndexes = @(
                for ($index = $permissionStart + 1; $index -lt $permissionEnd; $index++) {
                    if ($lines[$index] -match '^  bash(?:$|[\s:])') {
                        $index
                    }
                }
            )

            if ($bashMapIndexes.Count -ne 1 -or $bashLikeIndexes.Count -ne 1) {
                throw "Agent frontmatter must contain exactly one direct bash map."
            }
            if ([int]$bashMapIndexes[0] -ne [int]$bashLikeIndexes[0]) {
                throw "The direct bash map must use the canonical bash: entry."
            }

            $bashStart = [int]$bashMapIndexes[0]
            $bashEnd = $permissionEnd
            for ($index = $bashStart + 1; $index -lt $permissionEnd; $index++) {
                if ($lines[$index] -match '^  \S') {
                    $bashEnd = $index
                    break
                }
            }

            $permissions = [ordered]@{}
            for ($index = $bashStart + 1; $index -lt $bashEnd; $index++) {
                $entry = [regex]::Match($lines[$index], '^    "([^"]+)": (allow|ask|deny)$')
                if (-not $entry.Success -or $entry.Groups[1].Value.Length -eq 0) {
                    throw "Bash permission entries must use the canonical four-space form."
                }

                $key = $entry.Groups[1].Value
                if ($permissions.Contains($key)) {
                    throw "Duplicate Bash permission key: $key"
                }

                $permissions.Add($key, $entry.Groups[2].Value)
            }

            return ,$permissions
        }

        $repoRoot = Join-Path $PSScriptRoot ".."
        $configRoot = Join-Path $repoRoot "config"

        $script:openCodeConfig = Get-Content -LiteralPath (Join-Path $configRoot "opencode.json") -Raw | ConvertFrom-Json
        $script:architect = Get-Content -LiteralPath (Join-Path $configRoot "agents\architect.md") -Raw
        $script:lunaImplementer = Get-Content -LiteralPath (Join-Path $configRoot "agents\luna-implementer.md") -Raw
        $script:deepAdvisor = Get-Content -LiteralPath (Join-Path $configRoot "agents\deep-advisor.md") -Raw
        $script:reviewer = Get-Content -LiteralPath (Join-Path $configRoot "agents\code-reviewer.md") -Raw
        $script:readOnlyAgents = [ordered]@{
            "architect" = $script:architect
            "code-reviewer" = $script:reviewer
            "deep-advisor" = $script:deepAdvisor
        }
    }

    It "starts sessions with the Terra orchestrator and allows one delegation level" {
        $script:openCodeConfig.default_agent | Should -Be "architect"
        $script:openCodeConfig.subagent_depth | Should -Be 1
    }

    It "configures architect as a read-only Terra high primary agent" {
        $script:architect | Should -Match "(?m)^mode: primary$"
        $script:architect | Should -Match "(?m)^model: openai/gpt-5\.6-terra$"
        $script:architect | Should -Match "(?m)^variant: high$"
        $script:architect | Should -Match "(?m)^  edit: deny$"
    }

    It "limits architect delegation to the approved workflow agents" {
        $script:architect | Should -Match '(?m)^    "\*": deny$'
        $script:architect | Should -Match "(?m)^    luna-implementer: allow$"
        $script:architect | Should -Match "(?m)^    deep-advisor: allow$"
        $script:architect | Should -Match "(?m)^    code-reviewer: ask$"
    }

    It "uses Luna max for implementation without overriding global edit or bash permissions" {
        $script:lunaImplementer | Should -Match "(?m)^mode: subagent$"
        $script:lunaImplementer | Should -Match "(?m)^model: openai/gpt-5\.6-luna$"
        $script:lunaImplementer | Should -Match "(?m)^variant: max$"
        $script:lunaImplementer | Should -Match "(?m)^  task: deny$"
        $script:lunaImplementer | Should -Not -Match "(?m)^  edit:"
        $script:lunaImplementer | Should -Not -Match "(?m)^  bash:"
    }

    It "reserves Terra xhigh for the read-only deep adviser" {
        $script:deepAdvisor | Should -Match "(?m)^mode: subagent$"
        $script:deepAdvisor | Should -Match "(?m)^model: openai/gpt-5\.6-terra$"
        $script:deepAdvisor | Should -Match "(?m)^variant: xhigh$"
        $script:deepAdvisor | Should -Match "(?m)^  edit: deny$"
        $script:deepAdvisor | Should -Match "(?m)^  task: deny$"
    }

    It "keeps independent review read-only and avoids shell file-access bypasses" {
        $script:reviewer | Should -Match "(?m)^model: openai/gpt-5\.6-terra$"
        $script:reviewer | Should -Match "(?m)^variant: high$"
        $script:reviewer | Should -Match "(?m)^  edit: deny$"
        $script:reviewer | Should -Match "(?m)^  task: deny$"
        $script:reviewer | Should -Not -Match '(?m)^    "(cat|grep) \*": allow$'
    }

    It "enforces fail-closed metadata-only Bash permissions for read-only agents" {
        $expectedBashPermissions = [ordered]@{
            "*" = "deny"
            "git status --short" = "allow"
            "git branch --show-current" = "allow"
        }

        foreach ($agentName in $script:readOnlyAgents.Keys) {
            $actualBashPermissions = Get-AgentBashPermissions -Content $script:readOnlyAgents[$agentName]
            $actualKeys = @($actualBashPermissions.Keys)
            $expectedKeys = @($expectedBashPermissions.Keys)

            $actualKeys.Count | Should -Be $expectedKeys.Count
            ($actualKeys -join "`n") | Should -Be ($expectedKeys -join "`n")

            foreach ($key in $expectedKeys) {
                $actualBashPermissions[$key] | Should -Be $expectedBashPermissions[$key]
            }
        }
    }

    It "keeps architect delegation within budget guardrails" {
        $script:architect | Should -Match '(?m)^## Budget Guardrails$'
        $script:architect | Should -Match 'analysis-only and small tasks directly'
        $script:architect | Should -Match 'one active Luna task per request'
        $script:architect | Should -Match 'parallel or speculative retries'
        $script:architect | Should -Match 'one Deep Advisor pass'
        $script:architect | Should -Match 'one reviewer pass only'
        $script:architect | Should -Match 'at most one Luna continuation'
        $script:architect | Should -Match 'otherwise return a blocker'
    }
}
