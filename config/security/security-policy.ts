const sensitiveNames = new Set([
  ".npmrc",
  ".pypirc",
  ".yarnrc",
  "id_dsa",
  "id_ecdsa",
  "id_ed25519",
  "id_rsa",
])

const sensitiveExtensions = new Set([".key", ".p12", ".pem", ".pfx"])

export function isSensitivePath(value: string): boolean {
  const path = value.replace(/\\/g, "/").toLowerCase()
  const parts = path.split("/").filter(Boolean)

  return parts.some((part) => {
    if (part === "secrets" || part === "credentials") return true
    if (/^\.env(?:\..+)?$/.test(part)) return true
    if (sensitiveNames.has(part)) return true

    return [...sensitiveExtensions].some((extension) => part.endsWith(extension))
  })
}

export function classifyCommand(command: string): string | undefined {
  if (/\brm\s+-[a-z]*[rf][a-z]*\b/i.test(command)) return "recursive deletion"
  if (/\bremove-item\b(?=[^\n]*(?:-recurse|-r)(?=\s|$))(?=[^\n]*(?:-force|-f)(?=\s|$))/i.test(command)) {
    return "recursive deletion"
  }
  if (/\bgit\s+reset\s+--hard\b/i.test(command)) return "destructive git reset"
  if (/\bgit\s+clean\s+-[a-z]*f[a-z]*\b/i.test(command)) return "forced git clean"
  if (/\bgit\s+push\s+.*(?:--force(?:-with-lease)?\b|\s-f\b)/i.test(command)) return "force push"
  if (/\bgit\s+push\s+(?:\S+\s+)?(?:main|master)\b/i.test(command)) return "protected branch push"
  if (/\bmkfs(?:\.[\w-]+)?\b/i.test(command)) return "filesystem formatting"
  if (/\b(?:curl|wget)\b[^\n|]*\|\s*(?:ba)?sh\b/i.test(command)) return "download piped to shell"
}

export function containsSensitivePath(value: unknown): boolean {
  if (typeof value === "string") return isSensitivePath(value)
  if (Array.isArray(value)) return value.some(containsSensitivePath)
  if (value && typeof value === "object") return Object.values(value).some(containsSensitivePath)

  return false
}
