import { classifyCommand, containsSensitivePath } from "../security/security-policy"
import { createAuditLogger, type AuditEvent } from "../security/log"

const fileTools = new Set(["read", "write", "edit", "glob", "grep", "list"])

type BeforeInput = { tool: string; sessionID?: string; callID?: string }
type AfterInput = BeforeInput & { args: Record<string, unknown> }
type AuditLogger = ReturnType<typeof createAuditLogger>

export function createSecurityPlugin(options: { auditLogger?: AuditLogger; cwd?: string } = {}) {
  const auditLogger = options.auditLogger ?? createAuditLogger()
  const audit = (input: BeforeInput, event: AuditEvent) =>
    auditLogger.write({ sessionID: input.sessionID, callID: input.callID, cwd: options.cwd ?? process.cwd(), ...event })

  return {
    "tool.execute.before": async (input: BeforeInput, output: { args: Record<string, unknown> }) => {
      if (fileTools.has(input.tool) && containsSensitivePath(output.args)) {
        throw new Error("Access to sensitive files is blocked by the global OpenCode security policy.")
      }

      if (input.tool === "bash") {
        const command = output.args.command
        if (typeof command !== "string") {
          await audit(input, { event: "blocked", reason: "missing command", status: "blocked" })
          throw new Error("Bash commands without a string command are blocked by the global OpenCode security policy.")
        }

        const reason = classifyCommand(command)
        if (reason) {
          await audit(input, { event: "blocked", command, reason, status: "blocked" })
          throw new Error(`${reason} is blocked by the global OpenCode security policy.`)
        }

        await audit(input, { event: "attempt", command, decision: "allowed", status: "allowed" })
      }
    },
    "tool.execute.after": async (input: AfterInput, output: { output?: unknown; metadata: unknown }) => {
      if (input.tool !== "bash" || typeof input.args.command !== "string") return

      const exitCode = extractExitCode(output.metadata)
      await audit(input, {
        event: "completed",
        command: input.args.command,
        exitCode,
        outputPreview: previewOutput(output.output),
        status: typeof exitCode === "number" ? (exitCode === 0 ? "succeeded" : "failed") : "unknown",
      })
    },
  }
}

function previewOutput(output: unknown): string | undefined {
  if (typeof output !== "string") return undefined
  const preview = output.replace(/[\t\r\n]+/g, " ").trim()
  if (!preview) return undefined
  return preview.length > 300 ? `${preview.slice(0, 300)}...` : preview
}

export default async function securityPlugin(context?: { directory?: string }) {
  return createSecurityPlugin({ cwd: context?.directory })
}

function extractExitCode(metadata: unknown): number | undefined {
  if (!metadata || typeof metadata !== "object") return undefined

  const value = (metadata as Record<string, unknown>).exitCode
  return typeof value === "number" ? value : undefined
}
