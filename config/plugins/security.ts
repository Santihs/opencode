import { classifyCommand, containsSensitivePath } from "../security/security-policy"

const fileTools = new Set(["read", "write", "edit", "glob", "grep", "list"])

export default async function securityPlugin() {
  return {
    "tool.execute.before": async (input: { tool: string }, output: { args: Record<string, unknown> }) => {
      if (fileTools.has(input.tool) && containsSensitivePath(output.args)) {
        throw new Error("Access to sensitive files is blocked by the global OpenCode security policy.")
      }

      if (input.tool === "bash") {
        const command = output.args.command
        if (typeof command !== "string") {
          throw new Error("Bash commands without a string command are blocked by the global OpenCode security policy.")
        }

        const reason = classifyCommand(command)
        if (reason) {
          throw new Error(`${reason} is blocked by the global OpenCode security policy.`)
        }
      }
    },
  }
}
