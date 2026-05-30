# Sanitization scan — run BEFORE publishing your fork

If you fork this playbook and adapt it to your own setup, you'll eventually have *your* personal identifiers (workspace name, project names, ticket IDs, ntfy topic, hardware specifics) baked into your fork. Before pushing to a public repo, run this scan.

Generic recipes. Replace `<placeholder>` patterns with your own real values for the grep — then verify zero matches.

---

## What to look for

Before scanning, write down (privately) the list of personal identifiers in YOUR setup. Typical categories:

| Category | Example placeholder | Your real value (private — don't commit) |
|---|---|---|
| Your username (login on disk) | `<your-username>` | |
| Your real name(s) | `<your-name>` | |
| Your email | `<your-email>` | |
| PM tool workspace name | `<your-workspace>` | |
| PM team key / team UUID | `<your-team>` / `<team-uuid>` | |
| Project names (each one a separate row) | `<project-N>` | |
| Ticket IDs that are real, not illustrative | `<real-ticket-N>` | |
| ntfy topic name | `<your-ntfy-topic>` | |
| Password-manager entry names | `<entry-name>` | |
| Specific hostnames / cloud servers | `<host-N>` | |
| Phone OS / hardware specifics | `<phone-OS>` | |

Keep this list in a private note (NOT in the repo). The scan below uses it as the search corpus.

---

## 1. Personal name / username

```bash
# Replace placeholders with your real values; then run.
# After replacement, expect ZERO matches.
rg -i '<your-username>|/Users/<your-username>|<your-name>|<your-name-variant>' --hidden
```

**If found:** replace with `<u>` (in paths) or `<your-name>` (in prose).

---

## 2. Email addresses

```bash
rg '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' --hidden
```

**Expected:** only `<your-email@example.com>` style placeholders and noreply addresses (e.g., `noreply@anthropic.com` for Co-Authored-By trailers).

**If found unexpected:** replace with `<your-email@example.com>`.

---

## 3. PM tool identifiers

### 3.1 Workspace name

```bash
rg '<your-real-workspace>'
```

**Expected:** zero matches. All workspace references should be `<your-workspace>`.

### 3.2 Team key / UUID

```bash
# Your actual team key (replace placeholder)
rg '\bteam[_ -]?<your-key>\b' -i
# UUID format
rg '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
```

**Expected:** UUIDs should be `<team-uuid>`, `<project-uuid>`, etc. No real UUIDs.

### 3.3 Ticket IDs

```bash
# Linear-style IDs (replace prefix with yours)
rg '\b<YOUR-PREFIX>-[0-9]+\b' | sort -u
```

**Expected:**
- Illustrative IDs are OK if they're abstract (e.g., `G-XXX`, `G-1234`)
- Real ticket IDs from your workspace are NOT OK — replace with placeholder forms

### 3.4 Real project names

For each real project in your PM tool that you'd recognize on sight, grep for the slug:

```bash
# One pattern per project
rg -i '<project-1>|<project-2>|<project-3>'
```

**Expected:** zero matches in chapter prose. These names would identify your tree via `gh search` once published.

**If found:** replace with `<app-foo>`, `<bounded-project>`, `<continuous-area>`, etc.

---

## 4. Secrets-adjacent identifiers

### 4.1 ntfy topic names

```bash
rg 'ntfy\.sh/[a-z0-9-]{8,}' | grep -v 'ntfy\.sh/<your-' | grep -v 'ntfy\.sh/\$'
```

**Expected:** only `<your-ntfy-topic>` placeholders.

ntfy topic = effective password. Leaking it lets anyone push to your phone.

### 4.2 Password-manager entry names

The names of entries in your vault (like "Linear API", "GitHub PAT") are conventions, not secrets — safe to publish. But verify no token values appear adjacent:

```bash
# Look for long alphanumeric strings near password-manager invocations
rg -B2 -A2 'rbw get|op read|pass show' | grep -E '[A-Za-z0-9_/+]{32,}' | head
```

**Expected:** zero matches. If there's a string that LOOKS like a token next to a vault command, ROTATE first.

### 4.3 API key patterns (generic detection)

```bash
# Anthropic
rg 'sk-ant-[A-Za-z0-9_-]+'
# OpenAI
rg 'sk-[A-Za-z0-9]{32,}'
# GitHub
rg 'ghp_[A-Za-z0-9]{36,}|gho_[A-Za-z0-9]{36,}|ghs_[A-Za-z0-9]{36,}'
# AWS
rg 'AKIA[0-9A-Z]{16}'
# Slack
rg 'xox[bpars]-[A-Za-z0-9-]+'
# Generic high-entropy near "token", "key", "secret", "password"
rg -i '(token|key|secret|password)\s*[=:]\s*["'"'"'][A-Za-z0-9_/+]{20,}["'"'"']'
```

**Expected:** zero matches.

**If found:** **ROTATE THE SECRET IMMEDIATELY** (per [05-secrets-and-secure-defaults/never-commit-secrets.md](./05-secrets-and-secure-defaults/never-commit-secrets.md)). Then remove from the file.

---

## 5. Filesystem path leaks

### 5.1 Absolute paths with your home

```bash
rg '/Users/[a-zA-Z0-9_-]+/' | grep -v '/Users/<u>' | grep -v '/Users/YOU' | grep -v '/Users/<user>'
```

**Expected:** only placeholders.

### 5.2 Specific repo paths

```bash
rg 'Projects/(awesome|apps|tools|cases|infra|research|media|money|upstream)/[a-z][a-z-]+'
```

**Expected:** path skeletons like `~/Projects/<category>/<slug>` — NOT actual project names from your tree.

---

## 6. Dates that prematurely date the document

```bash
rg '\b(202[3-9]|203[0-9])-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])\b'
```

**Expected:**
- Dates inside `conventions-*.md` examples should be `<date>` placeholders
- Dates inside chapter prose where they're illustrative (e.g., feature ship year) are usually OK
- Real audit dates from your private timeline are NOT OK

**If found:** if the date dates the doc unhelpfully, generalize to `<date>` or "recently."

---

## 7. Hardware / setup specifics that personalize too narrowly

```bash
# Generic personalization markers — search prose for anything suggesting your specific setup
rg -i 'my (mac|laptop|phone|server|VPS|router|machine|setup)|i (use|run|have|own)'
```

**Expected:** chapter prose should use "you / your" framing, not "I / my." Audit each result.

---

## 8. The "fresh-eyes scan"

After running all of the above and fixing findings, do this final pass:

1. **Read the top-level `README.md` cold.** Imagine you're a stranger landing here. Any line that reads as "this is one specific person's setup, not transferable" is a sanitization gap.

2. **Sample 3 random sub-topic files.** Same test.

3. **Open `examples/`.** Each example file's placeholders should be obvious enough that a reader can adapt without head-scratching.

4. **Check `extraction-sheet.md`.** Verify the sanitization table reflects what's actually in the repo.

---

## 9. Mechanical secret scan with off-the-shelf tools

Beyond the manual scan, run published secret-scanners:

```bash
# detect-secrets — Yelp's tool
pip install detect-secrets
detect-secrets scan --all-files . | jq '.results | keys'
# Empty array → clean. Non-empty → investigate each file.

# gitleaks — independent scanner with curated patterns
brew install gitleaks
gitleaks detect --no-git --source . --verbose
# Exit code 0 → clean. Non-zero → findings.
```

Either / both. Two scanners with different rule sets catch more than one.

---

## 10. The push-day procedure

Once all of the above pass:

```bash
# Copy your sanitized fork to its new home
cp -r <your-fork-dir>/repo ~/Projects/awesome/<your-name-for-the-repo>
cd ~/Projects/awesome/<your-name-for-the-repo>

# Optionally remove this scan doc — it's about pre-publish scanning,
# which the readers of your published repo don't need.
# (Or keep if you want to invite others to scan their own forks.)

# Final secret scan
detect-secrets scan --all-files . | jq '.results | keys'   # should be []

# Init and commit
git init
git add .
git commit -m "Initial v0 from <your-name-for-the-repo> playbook fork"

# Create the GitHub repo (public)
gh repo create <your-name-for-the-repo> --public --source=. --push
```

After push, do one last fresh-eyes scan on the *rendered* GitHub view — sometimes things look fine in source but expose personal info via rendered markdown link previews, image alt text, etc.

---

## Tracking your scan

When you run this scan, log results privately (in your meta-PM repo's audits, not in the published one). The audit captures:

- Date scan was run
- Which sections turned up findings
- What was changed
- Final verdict (cleared for push / additional pass needed)

After 2-3 forks shipped using this procedure, the scan stabilizes. Promote your refined version to `~/.claude/docs/pre-publish-sanitization-scan.md` for reuse across future publishing.

---

## What this scan is NOT

- **Not a guarantee of zero leak.** Manual scans miss things. Pair with `detect-secrets` + `gitleaks` mechanical scans.
- **Not a substitute for design discipline.** The best sanitization is "the personal info was never in the v0 in the first place." This scan is the safety net.
- **Not foolproof for image leaks.** If you ship screenshots, they may contain visible personal info. Crop / redact before publishing.
- **Not legal review.** If your jurisdiction has rules about what can be published (NDAs, employment agreements), this scan doesn't address those.
