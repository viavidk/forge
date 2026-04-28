# /project:health

Check that all MCP servers in .mcp.json are reachable and that required
runtimes (node, npx) are available.

## Steps

1. Spawn `mcp-health-check` agent
2. Wait for the report
3. If any server FAILS: output the specific fix command
4. If all PASS: output "All MCP servers operational"

## When to run

- After initial project setup to verify MCP configuration
- When MCP-dependent features (Context7 docs, Chrome DevTools testing,
  ViaVi Skills) stop working
- After updating .mcp.json
