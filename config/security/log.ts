import { appendFile, mkdir } from "node:fs/promises"
import { dirname, join } from "node:path"
import { fileURLToPath } from "node:url"

const recordedEventIds = new Set<string>()
const pendingEventIds = new Set<string>()
const maxRecordedEventIds = 4096

export type AuditEvent = {
  event: "attempt" | "blocked" | "completed"
  sessionID?: string
  callID?: string
  cwd?: string
  command?: string
  decision?: "allowed"
  reason?: string
  exitCode?: number
}

export function auditFileName(date: Date): string {
  return `log_${date.toISOString().slice(0, 10)}.log`
}

export function redactCommand(command: string): string {
  return command
    .replace(/\b([a-z][a-z0-9_]*(?:token|password|pass|secret|api_?key|key|url|uri|connection_string))=\S+/gi, "$1=[REDACTED]")
    .replace(/(--(?:api[-_]?key|token|password|secret)(?:=|\s+))\S+/gi, "$1[REDACTED]")
    .replace(/(authorization\s*:\s*)(?:bearer\s+)?[^\s'"`]+/gi, "$1[REDACTED]")
    .replace(/([?&](?:api[-_]?key|access[-_]?token|token|password|secret)=)[^&#\s]+/gi, "$1[REDACTED]")
}

export function createAuditLogger(auditDirectory = defaultAuditDirectory()) {
  return {
    async write(event: AuditEvent): Promise<void> {
      const eventID = event.callID ? `${auditDirectory}:${event.event}:${event.callID}` : undefined
      if (eventID && (recordedEventIds.has(eventID) || pendingEventIds.has(eventID))) return

      if (eventID) pendingEventIds.add(eventID)
      try {
        await mkdir(auditDirectory, { recursive: true })
        const record = {
          schema: 1,
          timestamp: new Date().toISOString(),
          ...event,
          ...(event.command ? { command: redactCommand(event.command) } : {}),
        }
        await appendFile(join(auditDirectory, auditFileName(new Date())), `${JSON.stringify(record)}\n`, "utf8")
        if (eventID) rememberEvent(eventID)
      } catch {
        // Audit storage must never bypass a block or disrupt an approved command.
      } finally {
        if (eventID) pendingEventIds.delete(eventID)
      }
    },
  }
}

function defaultAuditDirectory(): string {
  return join(dirname(fileURLToPath(import.meta.url)), "..", "audit")
}

function rememberEvent(eventID: string): void {
  recordedEventIds.add(eventID)
  if (recordedEventIds.size <= maxRecordedEventIds) return

  recordedEventIds.delete(recordedEventIds.values().next().value!)
}
