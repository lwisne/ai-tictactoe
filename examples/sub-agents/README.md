# Multi-Agent Development Workflow Example

This example demonstrates a sophisticated multi-agent workflow orchestration system using Claude Code's agent capabilities. It showcases how specialized AI agents can collaborate to manage the complete software development lifecycle, from product planning through implementation, testing, and code review.

## What This Example Demonstrates

This template implements a **7-agent system** that automates and coordinates different aspects of software development:

1. **Product Management** - PRD creation and validation
2. **Project Management** - Task breakdown and orchestration
3. **Architecture Governance** - Standards enforcement and design review
4. **UX Design Review** - User experience validation
5. **Implementation** - Code writing with standards compliance
6. **Testing** - Test coverage analysis and gap identification
7. **Code Review** - Technical correctness and quality assurance

The agents work together through a structured workflow, with each agent having specific responsibilities, quality gates, and handoff protocols. This creates a development process where quality is built in at every stage, not just checked at the end.

## The 7 Specialized Agents

### 1. Product Manager (PRD)
**File:** `.claude/agents/product-manager-prd.md`

Validates implemented features against product requirements, tests user flows, and ensures alignment with PRD documentation. Acts as the guardian of product quality.

**Key Responsibilities:**
- PRD validation and requirements verification
- User flow testing and acceptance criteria checking
- Gap analysis and feature completeness assessment
- User experience assessment

### 2. Project Manager
**File:** `.claude/agents/project-manager.md`

Orchestrates work across multiple agents, creates Linear issues for development tasks, and coordinates the overall development workflow.

**Key Responsibilities:**
- Breaking down features into Linear tasks
- Agent coordination and work assignment
- Quality assurance integration
- Project planning and progress tracking

### 3. Architecture Guardian
**File:** `.claude/agents/architecture-guardian.md`

Establishes, documents, and enforces architectural standards across the codebase. Maintains the technical-architecture.md as the single source of truth.

**Key Responsibilities:**
- Architecture documentation management
- PRD architecture integration
- Code architecture validation
- Proactive architecture guidance

### 4. UX Design Reviewer
**File:** `.claude/agents/ux-design-reviewer.md`

Ensures coherent, intuitive, and delightful user experiences across product requirements and code implementations.

**Key Responsibilities:**
- PRD review for UX coherence
- Code implementation review against UX requirements
- Accessibility and usability assessment
- User flow analysis

### 5. Linear Task Implementer
**File:** `.claude/agents/linear-task-implementer.md`

Translates Linear task requirements into production-ready code that strictly adheres to established project architecture and coding standards.

**Key Responsibilities:**
- Task analysis and planning
- Standards-compliant implementation
- Test coverage creation
- Quality assurance process

### 6. Code Tester
**File:** `.claude/agents/code-tester.md`

Ensures comprehensive test coverage for all code changes, identifying test gaps and verifying coverage against requirements.

**Key Responsibilities:**
- Requirements analysis for test scenarios
- Test coverage assessment
- Gap identification and prioritization
- Test quality evaluation

### 7. Code Reviewer
**File:** `.claude/agents/code-reviewer.md`

Reviews code for technical correctness, adherence to PRD requirements, architectural standards, and code quality best practices.

**Key Responsibilities:**
- Technical correctness verification
- PRD and architecture adherence checking
- Code quality and standards compliance
- Testing and quality assurance validation

## Quick Start Guide

### Prerequisites

Before using this multi-agent system, you need:

1. **Claude Code CLI** installed and configured
2. **Linear account** (for project management features)
3. **Basic understanding** of your project's tech stack
4. **VSCode** with your project's formatting configuration

See [SETUP.md](.claude/SETUP.md) for detailed setup instructions.

### Basic Usage

#### 1. Starting a New Feature

Invoke the Project Manager to break down your feature into tasks:

```bash
# In your project directory
claude-code

> "I need to implement user authentication with login and registration"
```

The Project Manager will create Linear tasks and coordinate the workflow.

#### 2. Implementing a Linear Task

Once you have a Linear task ID, use the Task Implementer:

```bash
> "Implement LWI-123 for user authentication"
```

The Task Implementer will write code following your project's standards.

#### 3. Running Quality Gates

Before pushing code, agents automatically run through quality gates:

- **Code Tester** ensures test coverage
- **Code Reviewer** validates technical correctness
- **Architecture Guardian** verifies architectural compliance

#### 4. PRD Validation

After implementing a feature, validate against product requirements:

```bash
> "Validate the authentication feature against the PRD"
```

The Product Manager agent will test user flows and verify requirements.

### Agent Invocation

Agents can be invoked in several ways:

1. **Natural Language:** Simply describe what you need
2. **Explicit Agent Reference:** Mention the agent by name
3. **Automatic Handoff:** Agents invoke each other based on workflow stage

See [WORKFLOW.md](.claude/WORKFLOW.md) for detailed workflow sequences.

## Project Structure

```
examples/sub-agents/
├── README.md                          # This file
├── EXAMPLE_WALKTHROUGH.md            # Step-by-step implementation example
├── PRD.md                            # Sample Tic-Tac-Toe product requirements
│
├── .claude/
│   ├── WORKFLOW.md                   # Agent interaction patterns and lifecycle
│   ├── SETUP.md                      # Configuration and setup guide
│   ├── settings.local.json           # Permissions configuration
│   ├── technical-architecture.md     # Architecture standards (example)
│   ├── testing-requirements.md       # Testing standards (example)
│   │
│   └── agents/
│       ├── product-manager-prd.md
│       ├── project-manager.md
│       ├── architecture-guardian.md
│       ├── ux-design-reviewer.md
│       ├── linear-task-implementer.md
│       ├── code-tester.md
│       └── code-reviewer.md
```

## Workflow Overview

The multi-agent system follows a structured development lifecycle:

```
1. Planning Phase
   ├─> Product Manager: Define requirements
   ├─> Architecture Guardian: Review architecture needs
   └─> UX Design Reviewer: Validate user experience

2. Task Management Phase
   └─> Project Manager: Break down into Linear tasks

3. Implementation Phase
   ├─> Linear Task Implementer: Write code
   └─> Architecture Guardian: Validate patterns

4. Quality Assurance Phase
   ├─> Code Tester: Verify test coverage
   ├─> Code Reviewer: Technical review
   └─> Product Manager: PRD validation

5. Completion
   └─> Project Manager: Coordinate merge
```

See the [workflow diagram](.claude/WORKFLOW.md) for detailed interaction sequences.

## Adapting This Template to Your Project

This template is designed to be customized for different tech stacks and development workflows:

### 1. Update Architecture Standards

Edit `.claude/technical-architecture.md` to reflect your:
- Technology stack and frameworks
- Architectural patterns (MVC, Clean Architecture, etc.)
- Design principles and best practices
- Code organization conventions
- Integration patterns

### 2. Customize Testing Requirements

Modify `.claude/testing-requirements.md` for your:
- Testing frameworks (Jest, Pytest, Flutter test, etc.)
- Coverage thresholds
- Test organization patterns
- Mocking and fixture strategies

### 3. Configure Permissions

Update `.claude/settings.local.json` to:
- Allow access to your codebase paths
- Configure MCP integrations (Notion, Linear, GitHub, etc.)
- Set appropriate read/write permissions

### 4. Adjust Agent Prompts

Customize agent files in `.claude/agents/` to:
- Reflect your team's terminology
- Add project-specific requirements
- Include tech stack-specific guidance
- Modify workflow handoff patterns

### 5. Define Your PRD Format

Create or adapt `PRD.md` to match your:
- Product requirements structure
- Acceptance criteria format
- Technical specifications template
- Success metrics definition

## Key Features

### Quality Gates

Every change passes through multiple quality gates:

- **Architecture Compliance:** Verified by Architecture Guardian
- **Test Coverage:** Validated by Code Tester
- **Code Quality:** Reviewed by Code Reviewer
- **PRD Alignment:** Checked by Product Manager
- **UX Coherence:** Assessed by UX Design Reviewer

### Automated Coordination

Agents automatically hand off work to each other:

- Implementation triggers testing analysis
- Code review triggers architecture validation
- PRD updates trigger UX review
- Task creation triggers implementation planning

### Standards Enforcement

Project standards are enforced consistently:

- Branch naming conventions
- Test coverage requirements
- Code formatting rules
- Architecture patterns
- Documentation requirements

### Comprehensive Documentation

The system maintains documentation automatically:

- Architecture decisions and patterns
- Testing strategies and coverage
- Implementation approaches
- Quality metrics and findings

## Example: Tic-Tac-Toe Project

This template includes a complete example based on a Tic-Tac-Toe mobile app built with Flutter. The example demonstrates:

- Complete PRD with user flows and acceptance criteria
- Architecture standards for Flutter/Dart projects
- Testing requirements for mobile applications
- Multi-agent coordination for feature development

See [EXAMPLE_WALKTHROUGH.md](EXAMPLE_WALKTHROUGH.md) for a step-by-step guide of implementing a feature from start to finish using the multi-agent system.

## Benefits of This Approach

### For Solo Developers

- Comprehensive review without needing another person
- Consistent quality across all code
- Automated documentation of decisions
- Structured workflow reduces cognitive load

### For Teams

- Consistent standards enforcement across team members
- Clear handoff protocols between development stages
- Automated quality gates reduce manual review burden
- Living documentation stays current

### For Learning

- Demonstrates best practices in software development
- Shows how to structure complex workflows
- Provides templates for documentation and standards
- Illustrates agent coordination patterns

## Advanced Usage

### Sequential vs Parallel Agent Execution

Some workflows benefit from parallel agent execution:

```bash
# Parallel: Review architecture AND UX simultaneously
> "Review the checkout feature for both architecture and UX compliance"
```

Others require sequential execution:

```bash
# Sequential: Implement, then test, then review
> "Implement LWI-456, then verify test coverage"
```

### Custom Agent Chains

Create custom workflows by explicitly requesting agent sequences:

```bash
> "Use the product manager to validate requirements, then the architecture guardian to define patterns, then create Linear tasks"
```

### Agent Configuration

Customize agent behavior through:

- Model selection (inherit, or specify model)
- Color coding for visual identification
- Description prompts for invocation guidance
- Custom instructions in agent files

## Troubleshooting

### Agents Not Invoking Each Other

- Check that agent descriptions include invocation examples
- Verify that agent names match file names
- Ensure workflow handoff points are clear in agent prompts

### Standards Not Being Enforced

- Verify technical-architecture.md is up to date
- Check that Architecture Guardian references the standards file
- Ensure all agents include standards compliance in their prompts

### Test Coverage Gaps

- Review testing-requirements.md for completeness
- Ensure Code Tester agent has access to test files
- Verify that test frameworks are properly configured

## Contributing to This Template

This template is designed to evolve based on real-world usage. When adapting it:

1. Document any new patterns you discover
2. Share agent prompt improvements
3. Contribute workflow optimizations
4. Report issues or unclear documentation

## Resources

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [Agent System Guide](https://docs.anthropic.com/claude-code/agents)
- [WORKFLOW.md](.claude/WORKFLOW.md) - Detailed workflow diagrams
- [SETUP.md](.claude/SETUP.md) - Complete setup instructions
- [EXAMPLE_WALKTHROUGH.md](EXAMPLE_WALKTHROUGH.md) - Concrete implementation example

## License

This example template is provided as-is for educational and development purposes. Adapt it freely to your needs.

---

Built with Claude Code - AI-powered software development
