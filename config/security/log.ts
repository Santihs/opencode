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
  outputPreview?: string
  exitCode?: number
  status?: "allowed" | "blocked" | "succeeded" | "failed" | "unknown"
}

export function auditFileName(date: Date): string {
  const pad = (value: number) => String(value).padStart(2, "0")
  return `log_${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}.log`
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
        const date = new Date()
        await appendFile(join(auditDirectory, auditFileName(date)), `${formatAuditEvent(event, date)}\n`, "utf8")
        if (eventID) rememberEvent(eventID)
      } catch {
        // Audit storage must never bypass a block or disrupt an approved command.
      } finally {
        if (eventID) pendingEventIds.delete(eventID)
      }
    },
  }
}

export function formatAuditEvent(event: AuditEvent, date = new Date()): string {
  return [
    formatLocalTimestamp(date),
    event.sessionID ?? "-",
    event.event,
    event.status ?? statusFor(event),
    event.exitCode ?? "-",
    event.callID ?? "-",
    event.cwd ?? "-",
    event.reason ?? "-",
    event.outputPreview ? redactCommand(event.outputPreview) : "-",
    event.command ? redactCommand(event.command) : "-",
  ]
    .map((value) => sanitizeField(String(value)))
    .join("\t")
}

function formatLocalTimestamp(date: Date): string {
  const pad = (value: number, length = 2) => String(value).padStart(length, "0")
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())} ${pad(date.getHours())}:${pad(date.getMinutes())}:${pad(date.getSeconds())}.${pad(date.getMilliseconds(), 3)}`
}

function sanitizeField(value: string): string {
  return value.replace(/[\t\r\n]+/g, " ")
}

function statusFor(event: AuditEvent): "allowed" | "blocked" | "succeeded" | "failed" | "unknown" {
  if (event.event === "attempt") return event.decision === "allowed" ? "allowed" : "unknown"
  if (event.event === "blocked") return "blocked"
  if (event.exitCode === 0) return "succeeded"
  if (typeof event.exitCode === "number") return "failed"
  return "unknown"
}

function defaultAuditDirectory(): string {
  return join(dirname(fileURLToPath(import.meta.url)), "..", "audit")
}

function rememberEvent(eventID: string): void {
  recordedEventIds.add(eventID)
  if (recordedEventIds.size <= maxRecordedEventIds) return

  recordedEventIds.delete(recordedEventIds.values().next().value!)
}
