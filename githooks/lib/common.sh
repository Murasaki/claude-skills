# Shared helpers for the git hooks in this folder. Sourced, not executed.
# shellcheck shell=bash

HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GITLEAKS_CONFIG="$HOOKS_DIR/gitleaks.toml"

red()    { printf '\033[31m%s\033[0m\n' "$*" >&2; }
yellow() { printf '\033[33m%s\033[0m\n' "$*" >&2; }
info()   { printf '%s\n' "$*" >&2; }

# With a global core.hooksPath, git ignores each repo's own .git/hooks. Run the repo's hook too,
# if it has one, so per-repo hooks keep working. Stdin is passed through.
run_repo_hook() {
    local name="$1"; shift
    local hook
    hook="$(git rev-parse --git-common-dir)/hooks/$name"
    if [ -x "$hook" ]; then
        "$hook" "$@"
    fi
}

require_gitleaks() {
    if ! command -v gitleaks >/dev/null 2>&1; then
        red "gitleaks is not installed, so this commit/push can't be scanned for secrets."
        info "Install it:  winget install --id Gitleaks.Gitleaks --exact"
        info "Bypass once: SKIP_SECRET_SCAN=1 git ..."
        return 1
    fi
}

# Paths the repo deliberately allows past the privacy checks: glob patterns, one per line, in
# .privacy-allow at the repo root ('#' comments allowed). gitleaks has its own .gitleaksignore.
is_privacy_allowed() {
    local path="$1" pattern allow_file
    allow_file="$(git rev-parse --show-toplevel)/.privacy-allow"
    [ -f "$allow_file" ] || return 1
    while IFS= read -r pattern || [ -n "$pattern" ]; do
        pattern="${pattern%%#*}"
        pattern="$(printf '%s' "$pattern" | sed 's/[[:space:]]*$//')"
        [ -z "$pattern" ] && continue
        # shellcheck disable=SC2053  # glob match is intended
        [[ "$path" == $pattern ]] && return 0
    done < "$allow_file"
    return 1
}

# Files that should never be committed, by name.
is_blocked_name() {
    local base="${1##*/}"
    case "$base" in
        .env.example|.env.sample|.env.template) return 1 ;;
        .env|.env.*|*.env) echo "environment file (usually holds secrets)"; return 0 ;;
        settings.local.json) echo "machine-specific Claude Code settings (often holds secrets)"; return 0 ;;
        CLAUDE.local.md) echo "machine-specific notes (kept out of git by design)"; return 0 ;;
        *.pfx|*.p12|*.pem|*.key|*.ppk|id_rsa|id_ed25519|id_ecdsa) echo "private key or certificate"; return 0 ;;
        *.kdbx) echo "password database"; return 0 ;;
    esac
    return 1
}

# A CSV whose header names a person-identifying column and that has at least one data row.
# Reads the staged blob ($2 = git object spec, e.g. ":path"), not the working-tree file.
csv_personal_column() {
    local spec="$1" header rows
    header="$(git show "$spec" 2>/dev/null | head -n 1 | tr -d '\r' | sed 's/^\xEF\xBB\xBF//')"
    rows="$(git show "$spec" 2>/dev/null | sed 1d | grep -c '[^[:space:],]')"
    [ "${rows:-0}" -gt 0 ] || return 1
    printf '%s\n' "$header" | tr ',;\t' '\n\n\n' | tr -d '"' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
        | grep -ixE '(full |first |last |sur|given |pupil |student |child |customer |employee )?names?|surname|forename|e-?mail( address)?|phone( number)?|mobile|address|post ?code|zip|dob|date of birth|ni number|national insurance( number)?|upn|ssn' \
        | head -n 1
}
