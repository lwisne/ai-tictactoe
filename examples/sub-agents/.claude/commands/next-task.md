---
description: Fetch the next Linear task to work on from a project
args:
  - name: project_name
    description: The project name (optional - defaults to "AI Tic-tac-toe")
    required: false
---

Fetch the next Linear task from the "$1" project (defaults to "AI Tic-tac-toe"):

1. **Query Linear Issues:**
   ```
   Use mcp__linear__list_issues with:
   - team: "Lwisne"
   - project: "$1" (or "AI Tic-tac-toe")
   - state: "Backlog"
   - limit: 10
   ```

2. **Filter Results:**
   - Only show tasks with `parentId` (sub-tasks, not epics)
   - Sort by priority: Urgent (1) > High (2) > Normal (3) > Low (4)
   - Select the highest priority sub-task

3. **Get Parent Epic Info:**
   - Fetch parent task using `mcp__linear__get_issue`
   - Extract epic branch name from parent description
   - Look for pattern: `**Epic Branch**: lwisne/...`

4. **Display Task Details:**
   Format as:
   ```
   📋 Next Task: [ID]
   
   Title: [title]
   Status: [status]
   Priority: [priority name]
   Parent: [parent ID] ([parent title])
   Epic Branch: [epic branch name]
   
   Description:
   [description]
   
   Labels: [labels]
   
   🔗 [Linear URL]
   
   Next Steps:
   To start working on this task, run:
   /implement [ID]
   ```

5. **Fallback:**
   - If no Backlog tasks with parent found, show message:
     "No sub-tasks in Backlog. Check Epic tasks or In Progress items."

IMPORTANT: Only show actual sub-tasks (with parentId), not epic-level tasks.
