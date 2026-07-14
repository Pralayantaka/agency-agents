#!/usr/bin/env bash
#
# generate-claude-skills.sh — Generate one Claude Code skill per Agency division.
#
# Each skill is a lightweight router: when a task matches a division's domain,
# the skill loads and shows the division roster and instructs Claude to read
# the chosen specialist's persona file from this clone and adopt it.
#
# Output: ~/.claude/skills/agency-<division>/SKILL.md  (user-wide skills)
# Re-run after `git pull` to refresh rosters. Idempotent.
#
# Usage: bash generate-claude-skills.sh [--skills-dir <dir>]

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="${HOME}/.claude/skills"
[[ "${1:-}" == "--skills-dir" && -n "${2:-}" ]] && SKILLS_DIR="$2"

# Windows-style path for display inside the skills (Claude reads these with the Read tool)
WINREPO="$(cygpath -w "$REPO" 2>/dev/null || echo "$REPO")"

DIVISIONS=(academic design engineering finance game-development gis healthcare
  marketing paid-media product project-management sales security
  spatial-computing specialized support testing)

label() {
  case "$1" in
    academic) echo "Academic";; design) echo "Design";; engineering) echo "Engineering";;
    finance) echo "Finance";; game-development) echo "Game Development";; gis) echo "GIS";;
    healthcare) echo "Healthcare";; marketing) echo "Marketing";; paid-media) echo "Paid Media";;
    product) echo "Product";; project-management) echo "Project Management";; sales) echo "Sales";;
    security) echo "Security";; spatial-computing) echo "Spatial Computing";;
    specialized) echo "Specialized";; support) echo "Support";; testing) echo "Testing";;
  esac
}

description() {
  case "$1" in
    academic) echo "Scholarly research specialists from The Agency (historian, psychologist, statistician, anthropologist, geographer, narratologist). Use whenever the task needs research design, statistical analysis, historical or cultural context, narrative/story theory, survey design, or behavioral interpretation — even if the user never says 'academic'.";;
    design) echo "UI/UX and brand design specialists (UI designer, UX architect, UX researcher, brand guardian, visual storyteller, image prompt engineer, inclusive visuals, whimsy injector). Use whenever the user asks about interface design, wireframes, mockups, design systems, branding, visual identity, user research, usability, AI image prompts, or making a product feel more delightful.";;
    engineering) echo "49 software-engineering specialist personas: frontend, backend, mobile, AI/ML, DevOps, SRE, embedded firmware, networking, blockchain/Solidity, data engineering, database tuning, CMS (WordPress/Drupal), prompt engineering, multi-agent systems, incident response, code review, technical writing. Use for any substantial build, architecture, review, or optimization task where a deep specialist would beat generic coding — even if the user doesn't name one.";;
    finance) echo "Finance specialists: bookkeeper/controller, financial analyst, FP&A analyst, investment researcher, tax strategist. Use whenever the user mentions budgets, forecasts, financial models, unit economics, cash flow, P&L, valuations, taxes, or accounting cleanup — even informal 'can I afford this' business questions.";;
    game-development) echo "Game-development specialists: game/level/narrative designers, game audio engineer, technical artist, plus engine experts for Unity, Unreal Engine, Godot, Roblox Studio, and Blender. Use whenever the user is building a game or interactive 3D experience — gameplay mechanics, shaders, multiplayer netcode, level layouts, engine-specific scripting, addon tooling, or 3D asset pipelines.";;
    gis) echo "Geospatial specialists: GIS analyst, cartography designer, spatial data engineer/scientist, GeoAI/ML, web GIS developer, drone/reality mapping, BIM/GIS, geoprocessing, 3D scenes. Use whenever the user works with maps, coordinates, satellite or drone imagery, shapefiles/GeoJSON, spatial queries, routing, or any location-based data — even a casual 'plot these points on a map'.";;
    healthcare) echo "Health-tech specialists: clinical evidence analysis, healthcare innovation strategy, sovereign health systems. Use whenever the task involves healthcare products, clinical workflows, medical evidence review, health-data regulation and privacy, or digital-health strategy.";;
    marketing) echo "36 marketing specialists: growth hacking, SEO/AEO/AI-citation optimization, content creation, email, PR, app-store optimization, podcasts, and platform experts for TikTok, Instagram, Reddit, X/Twitter, LinkedIn plus the full China stack (WeChat, Weibo, Douyin, Xiaohongshu, Zhihu, Bilibili, livestream commerce). Use whenever the user wants audience growth, content strategy, launch promotion, social posts, or channel-specific playbooks.";;
    paid-media) echo "Paid advertising specialists: PPC campaign strategy, paid social, programmatic/display buying, ad creative, search-query analysis, tracking & measurement, account audits. Use whenever the user mentions ad campaigns, Google/Meta ads, ROAS, ad budgets, conversion tracking, attribution, or auditing an ad account.";;
    product) echo "Product management specialists: product manager, feedback synthesizer, sprint prioritizer, trend researcher, behavioral nudge engine. Use whenever the user needs a roadmap, feature prioritization, user-feedback analysis, market or trend research, PRDs, or product strategy decisions — even when phrased as 'what should we build next'.";;
    project-management) echo "Project and delivery specialists: senior project manager, studio producer, project shepherd, Jira workflow steward, experiment tracker, meeting-notes specialist, studio operations. Use whenever the user needs project plans, sprint organization, status tracking, meeting summaries, Jira hygiene, or coordination to actually ship something.";;
    sales) echo "Sales specialists: outbound and offer strategy, discovery and deal coaching, sales engineering, proposal writing, pipeline analytics, account strategy. Use whenever the user mentions leads, cold outreach, CRM or pipeline, quotas, sales calls, demos, proposals/RFPs, or closing deals.";;
    security) echo "Security specialists: application security, penetration testing, threat modeling/detection/intelligence, cloud security architecture, blockchain auditing, incident response, compliance auditing, SecOps. Use whenever the user asks about vulnerabilities, security reviews, hardening, SOC 2 or compliance, suspicious activity, or designing systems securely.";;
    spatial-computing) echo "AR/VR/XR specialists: visionOS spatial engineer, XR interface architect, XR immersive developer, cockpit interaction, macOS Spatial/Metal engineer, terminal integration. Use whenever the user builds for Apple Vision Pro, AR/VR headsets, 3D spatial interfaces, Metal rendering, or immersive experiences.";;
    specialized) echo "54 niche-domain experts: legal (client intake, document review, billing), HR and recruitment, real estate, supply chain, ESG, grant writing, translation, CFO / chief-of-staff, Salesforce architecture, MCP builder, civil engineering, market entry (France, Korea, China), pricing analysis, organizational psychology, and more. Check this roster whenever a task needs professional domain expertise that doesn't fit the other divisions — before answering generically.";;
    support) echo "Operations and support specialists: support responder, analytics reporter, executive summary generator, finance tracker, infrastructure maintainer, legal compliance checker. Use whenever the user needs customer-support replies, help-desk workflows, recurring reports, executive summaries, or routine ops upkeep.";;
    testing) echo "QA and testing specialists: test automation (Playwright/Cypress), API testing, performance benchmarking, accessibility auditing, reality checking, test-results analysis, tool evaluation, workflow optimization. Use whenever the user wants test plans, E2E coverage, load tests, a11y audits, flaky-test debugging, or independent validation that something actually works.";;
  esac
}

extract_field() { # $1=file $2=field — first occurrence inside the frontmatter block
  awk -v key="$2" '
    /^---[[:space:]]*$/ { f++; next }
    f==1 && $0 ~ "^"key":" {
      sub("^"key":[[:space:]]*", ""); gsub(/^["'\'']|["'\'']$/, ""); print; exit
    }' "$1"
}

total=0
for div in "${DIVISIONS[@]}"; do
  out="$SKILLS_DIR/agency-$div"
  mkdir -p "$out"
  rows=""
  count=0
  while IFS= read -r file; do
    head -1 "$file" | grep -q '^---' || continue
    name="$(extract_field "$file" name)"
    desc="$(extract_field "$file" description | sed 's/|/\\|/g')"
    [[ -n "$name" ]] || continue
    winpath="$WINREPO\\$(echo "${file#./}" | tr '/' '\\')"
    rows+="| $name | $desc | \`$winpath\` |"$'\n'
    count=$((count+1))
  done < <(cd "$REPO" && find "./$div" -name "*.md" ! -name "README.md" -type f | sort)

  cat > "$out/SKILL.md" <<EOF
---
name: agency-$div
description: $(description "$div")
---

# The Agency — $(label "$div") Division ($count specialists)

This skill routes work to specialist AI personas from The Agency
(local clone: \`$WINREPO\`).

## How to use this skill

1. Scan the roster below and pick the specialist whose specialty best matches
   the task. If the user named a specialist, use that one.
2. Read the persona file (Read tool), then fully adopt it — identity, core
   mission, critical rules, technical deliverables, and communication style.
   Stay in persona while producing the deliverable.
3. If the task spans specialties, read the two or three closest personas and
   either blend them or hand off sequentially (e.g., design → build → review).
4. For large multi-phase projects, also consult the NEXUS orchestration
   playbook at \`$WINREPO\\strategy\\nexus-strategy.md\`
   (phase gates, handoff templates, activation prompts).

If a persona file is missing, the clone is stale or moved — run \`git pull\`
in the clone, re-run \`generate-claude-skills.sh\`, or re-clone from
https://github.com/Pralayantaka/agency-agents.

## Roster

| Specialist | Specialty | Persona file |
|---|---|---|
$rows
EOF
  echo "[OK] agency-$div ($count specialists)"
  total=$((total+count))
done

echo
echo "Generated ${#DIVISIONS[@]} skills covering $total specialists -> $SKILLS_DIR"
