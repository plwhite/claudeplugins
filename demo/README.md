# demo plugin

A deliberately minimal plugin used to verify that plugin discovery and wiring work correctly. It contains one skill and one agent, both of which return fixed, deterministic responses.

## Contents

| Type | Name | Description |
|------|------|-------------|
| Skill | `demo-skill` | Returns the literal string `hello` |
| Agent | `demo-agent` | Responds with the fixed sentence `demo-agent: ok` |

## Skills

### demo-skill

Returns a fixed response regardless of input. Use this to confirm that skill files are being discovered and loaded correctly.

**Invoke with:** `/demo-skill`

**Contract:**
- Input: any text
- Output: the literal string `hello`

## Agents

### demo-agent

Responds with a fixed sentence. Use this to confirm that agent files are being discovered and parsed correctly.

**Behaviour:**
- Responds with: `demo-agent: ok`
- If asked to "use demo-skill": responds with `hello`
- Does not attempt to solve any real task
