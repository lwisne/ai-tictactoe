# Multi-Agent System Setup Guide

This guide walks you through setting up the multi-agent development workflow system for your project. Follow these steps to configure Claude Code with the 7 specialized agents.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation Steps](#installation-steps)
- [Configuration](#configuration)
- [Linear Integration Setup](#linear-integration-setup)
- [Notion Integration Setup (Optional)](#notion-integration-setup-optional)
- [Customizing for Your Tech Stack](#customizing-for-your-tech-stack)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before setting up the multi-agent system, ensure you have:

### Required

1. **Claude Code CLI**
   - Version: Latest stable release
   - Installation: Follow [official installation guide](https://docs.anthropic.com/claude-code)
   - Verify installation: `claude-code --version`

2. **Project Repository**
   - Git repository initialized
   - Working directory with your codebase
   - Write access to create feature branches

3. **Linear Account**
   - Active Linear workspace
   - API key with read/write permissions
   - At least one project created

### Recommended

4. **VSCode**
   - With formatting configuration for your language
   - Extensions for your tech stack (e.g., Flutter, Dart, Python, JavaScript)

5. **Notion Account (Optional)**
   - For PRD management and documentation
   - API integration set up
   - Workspace with appropriate permissions

6. **Testing Framework**
   - Appropriate for your tech stack (Jest, Pytest, Flutter test, etc.)
   - Configured and working in your project

## Installation Steps

### Step 1: Clone or Initialize Template

If starting from this example:

```bash
# Copy the entire .claude directory to your project
cp -r /path/to/examples/sub-agents/.claude /path/to/your/project/

# Or if starting fresh in your project
mkdir -p .claude/agents
```

### Step 2: Configure Claude Code

Navigate to your project directory:

```bash
cd /path/to/your/project
claude-code
```

On first run, Claude Code will:
- Initialize configuration
- Request necessary permissions
- Set up agent system

### Step 3: Verify Agent Files

Ensure all agent files are present:

```bash
ls -la .claude/agents/
```

You should see:
- `product-manager-prd.md`
- `project-manager.md`
- `architecture-guardian.md`
- `ux-design-reviewer.md`
- `linear-task-implementer.md`
- `code-tester.md`
- `code-reviewer.md`

### Step 4: Create Configuration File

Create `.claude/settings.local.json`:

```bash
touch .claude/settings.local.json
```

## Configuration

### Basic Permissions Configuration

Edit `.claude/settings.local.json` to set up permissions:

```json
{
  "permissions": {
    "allow": [
      "Read(//path/to/your/project/**)",
      "Write(//path/to/your/project/**)",
      "Bash(cd:*)",
      "Bash(git:*)",
      "Bash(npm:*)",
      "Bash(flutter:*)"
    ],
    "deny": [
      "Write(//path/to/your/project/.git/**)",
      "Write(//path/to/your/project/node_modules/**)"
    ],
    "ask": [
      "Bash(rm:*)",
      "Bash(mv:*)"
    ]
  }
}
```

**Customize paths:**
- Replace `/path/to/your/project` with your actual project path
- Add tech-stack-specific commands (flutter, python, cargo, etc.)
- Add any additional protected directories to `deny`

### Advanced Permissions

For tighter security, you can specify more granular permissions:

```json
{
  "permissions": {
    "allow": [
      "Read(//Users/username/projects/myapp/src/**)",
      "Read(//Users/username/projects/myapp/test/**)",
      "Write(//Users/username/projects/myapp/src/**)",
      "Write(//Users/username/projects/myapp/test/**)",
      "Bash(cd:*)",
      "Bash(git:status)",
      "Bash(git:diff)",
      "Bash(git:add)",
      "Bash(git:commit)",
      "Bash(git:push)",
      "Bash(npm:test)",
      "Bash(npm:run:*)"
    ],
    "deny": [
      "Bash(git:push:*:main)",
      "Bash(rm:-rf:*)"
    ],
    "ask": [
      "Write(//Users/username/projects/myapp/.env)",
      "Bash(npm:install:*)"
    ]
  }
}
```

## Linear Integration Setup

### Step 1: Get Linear API Key

1. Go to [Linear Settings → API](https://linear.app/settings/api)
2. Click "Create new key"
3. Give it a descriptive name: "Claude Code Multi-Agent"
4. Copy the generated API key

### Step 2: Configure Linear MCP

Add Linear MCP server configuration. This is typically done in Claude Code's global configuration:

**For macOS/Linux:**
Edit `~/.config/claude-code/mcp_config.json`:

```json
{
  "mcpServers": {
    "linear": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-linear"],
      "env": {
        "LINEAR_API_KEY": "your_linear_api_key_here"
      }
    }
  }
}
```

**For Windows:**
Edit `%APPDATA%\claude-code\mcp_config.json`

### Step 3: Add Linear Permissions

Update `.claude/settings.local.json` to allow Linear MCP tools:

```json
{
  "permissions": {
    "allow": [
      "mcp__linear__list_issues",
      "mcp__linear__get_issue",
      "mcp__linear__create_issue",
      "mcp__linear__update_issue",
      "mcp__linear__list_projects",
      "mcp__linear__create_comment"
    ]
  }
}
```

### Step 4: Test Linear Integration

Start Claude Code and test:

```bash
claude-code

> "List my Linear issues"
```

If configured correctly, you should see your Linear issues.

## Notion Integration Setup (Optional)

### Step 1: Get Notion Integration Token

1. Go to [Notion Integrations](https://www.notion.so/my-integrations)
2. Click "New integration"
3. Name it "Claude Code Multi-Agent"
4. Copy the Internal Integration Token

### Step 2: Share Pages with Integration

1. Open your Notion workspace
2. Navigate to pages you want Claude Code to access (e.g., PRD pages)
3. Click "Share" → "Invite" → Select your integration
4. Grant appropriate access (read or write)

### Step 3: Configure Notion MCP

Add Notion configuration to `mcp_config.json`:

```json
{
  "mcpServers": {
    "linear": { /* ... existing linear config ... */ },
    "notion": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-notion"],
      "env": {
        "NOTION_API_KEY": "your_notion_token_here"
      }
    }
  }
}
```

### Step 4: Add Notion Permissions

Update `.claude/settings.local.json`:

```json
{
  "permissions": {
    "allow": [
      "mcp__notion__notion-search",
      "mcp__notion__notion-fetch",
      "mcp__notion__notion-create-pages",
      "mcp__notion__notion-update-page"
    ]
  }
}
```

## Customizing for Your Tech Stack

The example is built for a Flutter/Dart project. Adapt it for your stack:

### For React/TypeScript Projects

1. **Update `technical-architecture.md`:**

```markdown
## Technology Stack

- **Language:** TypeScript
- **Framework:** React 18+
- **State Management:** Redux Toolkit
- **Build Tool:** Vite
- **Testing:** Jest, React Testing Library
```

2. **Update `testing-requirements.md`:**

```markdown
## Testing Framework

- Unit tests: Jest
- Component tests: React Testing Library
- E2E tests: Playwright
- Coverage threshold: 80% statements
```

3. **Update agent prompts:**

In each agent file under "Project-Specific Requirements", change:

```markdown
- Use React hooks for state management
- Follow ESLint configuration for formatting
- Component files should be in PascalCase
- Test files should be co-located with components
```

### For Python/Django Projects

1. **Update `technical-architecture.md`:**

```markdown
## Technology Stack

- **Language:** Python 3.11+
- **Framework:** Django 4.2
- **Database:** PostgreSQL
- **Task Queue:** Celery
- **Testing:** Pytest, Django Test Framework
```

2. **Update `testing-requirements.md`:**

```markdown
## Testing Framework

- Unit tests: Pytest
- Integration tests: Django TestCase
- E2E tests: Playwright
- Coverage threshold: 90% statements
```

3. **Update agent prompts with Python-specific guidance:**

```markdown
- Follow PEP 8 style guidelines
- Use type hints for all function signatures
- Use Black for code formatting
- Organize code into Django apps
```

### For Node.js/Express Projects

1. **Update `technical-architecture.md`:**

```markdown
## Technology Stack

- **Language:** JavaScript (Node.js 18+)
- **Framework:** Express.js
- **Database:** MongoDB with Mongoose
- **Testing:** Jest, Supertest
```

2. **Update testing and formatting guidance in agent files**

## Updating Architecture Standards

### Step 1: Review Existing Standards

Read `.claude/technical-architecture.md` to understand the current structure.

### Step 2: Add Your Patterns

Add sections for your project's specific patterns:

```markdown
## Authentication Pattern

We use JWT-based authentication with the following flow:

1. User credentials sent to /auth/login
2. Server validates and returns JWT token
3. Client stores token in secure httpOnly cookie
4. Subsequent requests include token in Authorization header

### When to Use
- All API endpoints requiring user identity
- Protected routes in SPA

### When Not to Use
- Public endpoints (/health, /docs)
- Internal service-to-service calls (use service tokens)

### Implementation Example
\`\`\`typescript
// middleware/auth.ts
export const authenticate = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  // ...validation logic
};
\`\`\`
```

### Step 3: Document Anti-Patterns

Be explicit about what to avoid:

```markdown
## Anti-Patterns to Avoid

### Direct Database Access from Controllers
**Don't:**
\`\`\`typescript
// controller/user.ts
app.get('/users', (req, res) => {
  const users = db.query('SELECT * FROM users');
  res.json(users);
});
\`\`\`

**Do:**
\`\`\`typescript
// controller/user.ts
app.get('/users', async (req, res) => {
  const users = await userService.findAll();
  res.json(users);
});
\`\`\`
```

## Verification

### Test the Setup

1. **Verify agents are accessible:**

```bash
claude-code

> "List all available agents"
```

You should see all 7 agents listed.

2. **Test Linear integration:**

```bash
> "Create a test Linear issue in my project"
```

3. **Test architecture standards access:**

```bash
> "What are our documented architecture patterns?"
```

The Architecture Guardian should reference your technical-architecture.md.

4. **Test a simple workflow:**

```bash
> "Use the code-reviewer agent to review [filename]"
```

### Validate Permissions

Verify that agents can:
- Read files in your project
- Write files in appropriate directories
- Execute necessary bash commands
- Access MCP tools (Linear, Notion)

### Run Through a Complete Flow

Test the full workflow with a small task:

```bash
> "Use the project manager to break down a simple feature: add a health check endpoint"
```

Follow through each agent in the workflow to ensure handoffs work correctly.

## Troubleshooting

### Issue: Agents Not Found

**Symptoms:** "Agent not found" error when invoking agents

**Solutions:**
1. Verify agent files exist in `.claude/agents/`
2. Check that files have `.md` extension
3. Ensure agent `name` in frontmatter matches filename
4. Restart Claude Code

### Issue: Permission Denied Errors

**Symptoms:** "Permission denied" when agents try to read/write files

**Solutions:**
1. Check `.claude/settings.local.json` permissions
2. Ensure paths use absolute paths, not relative
3. Add specific paths to `allow` list
4. Check file system permissions

### Issue: Linear Integration Not Working

**Symptoms:** "Linear API error" or "Cannot connect to Linear"

**Solutions:**
1. Verify Linear API key is correct
2. Check that Linear MCP is properly configured in `mcp_config.json`
3. Ensure Linear permissions are in settings.local.json
4. Test API key manually with curl:

```bash
curl -H "Authorization: YOUR_API_KEY" https://api.linear.app/graphql
```

### Issue: Agents Using Wrong Standards

**Symptoms:** Architecture Guardian references Flutter patterns in a React project

**Solutions:**
1. Update `.claude/technical-architecture.md` for your stack
2. Clear any cached references in agent prompts
3. Explicitly reference your tech stack in agent descriptions
4. Update agent "Project-Specific Requirements" sections

### Issue: Commands Not Allowed

**Symptoms:** "Command not permitted" for bash commands

**Solutions:**
1. Add command patterns to `allow` list in settings.local.json
2. Use wildcards for flexible matching: `Bash(npm:*)`
3. Check for overly broad `deny` rules
4. Review command in `ask` list if you want manual approval

### Issue: MCP Servers Not Starting

**Symptoms:** MCP tools unavailable, "server failed to start"

**Solutions:**
1. Verify npx is installed: `npx --version`
2. Check MCP server package exists: `npm view @modelcontextprotocol/server-linear`
3. Look at Claude Code logs for detailed error messages
4. Try installing MCP servers globally: `npm install -g @modelcontextprotocol/server-linear`

## Advanced Configuration

### Custom Agent Chains

Create custom workflows by modifying agent descriptions to reference specific next steps:

```markdown
## Agent Coordination

After completing code review, this agent automatically:
1. Invokes Code Tester if test coverage is uncertain
2. Invokes Architecture Guardian if architectural concerns arise
3. Invokes Product Manager if PRD validation is needed
```

### Environment-Specific Settings

Create multiple settings files for different environments:

- `.claude/settings.development.json` - Full access for development
- `.claude/settings.review.json` - Read-only for code review
- `.claude/settings.production.json` - Restricted for production analysis

Switch between them by copying to `settings.local.json`.

### Project Templates

Create reusable templates for different project types:

```
.claude/
  templates/
    web-app/
      technical-architecture.md
      testing-requirements.md
    mobile-app/
      technical-architecture.md
      testing-requirements.md
    api-service/
      technical-architecture.md
      testing-requirements.md
```

Copy the appropriate template when starting a new project.

## Next Steps

After completing setup:

1. Read [WORKFLOW.md](WORKFLOW.md) to understand agent interactions
2. Try the [EXAMPLE_WALKTHROUGH.md](../EXAMPLE_WALKTHROUGH.md) to see the system in action
3. Customize agent prompts for your team's specific needs
4. Update technical-architecture.md with your patterns
5. Start using agents for real development work

## Getting Help

If you encounter issues not covered here:

1. Check Claude Code documentation
2. Review agent configuration in `.claude/agents/`
3. Examine logs for detailed error messages
4. Verify all prerequisites are met
5. Test components individually before full workflow

## Maintenance

### Regular Updates

Periodically review and update:

- **technical-architecture.md:** Add new patterns as they emerge
- **testing-requirements.md:** Update coverage thresholds and frameworks
- **Agent prompts:** Refine based on usage and feedback
- **settings.local.json:** Adjust permissions as needs change

### Version Control

Commit these files to version control:
- `.claude/agents/*.md`
- `.claude/technical-architecture.md`
- `.claude/testing-requirements.md`
- `.claude/WORKFLOW.md`
- `.claude/SETUP.md` (this file)

**Do not commit:**
- `.claude/settings.local.json` (may contain local paths)
- API keys or secrets in any configuration

### Sharing with Team

When onboarding team members:

1. Ensure they have all prerequisites installed
2. Provide them with Linear/Notion API keys
3. Have them follow this setup guide
4. Walk through the example walkthrough together
5. Review your project's architecture standards with them

---

Setup complete! You're now ready to use the multi-agent development workflow system.
