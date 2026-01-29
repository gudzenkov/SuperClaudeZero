#!/bin/bash
# SuperClaudeZero Installer
# Usage:
#   ./install.sh --global              Install to ~/.claude/
#   ./install.sh --project <path>      Install project templates to <path>
#   ./install.sh --all <path>          Both global and project installation
#   ./install.sh --overwrite           Overwrite existing files (backup to .bkp)
#   ./install.sh --cleanup             Remove installed artifacts, restore settings

set -e

VERSION="0.1.0 "
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
CREATED=0
PATCHED=0
UNCHANGED=0
WARNINGS=0
BACKUPS=0

# Options
OVERWRITE=false

# Print usage
usage() {
    cat << EOF
SuperClaudeZero Installer v${VERSION}

Usage:
    ./install.sh --global              Install to ~/.claude/
    ./install.sh --project <path>      Install project templates to <path>
    ./install.sh --all <path>          Both global and project installation
    ./install.sh --overwrite           Overwrite existing markdown files (backup to .bkp)
    ./install.sh --cleanup             Remove installed artifacts, restore settings from backup
    ./install.sh --help                Show this help

What gets installed:

--global installs to ~/.claude/:
    - agents/           Agent definitions (7 files)
    - skills/           Skill definitions (14 directories)
    - hooks/scripts/    Hook scripts (5 files)
    - settings.json     Hook and MCP configuration
    - policy/           RULES.md, PRINCIPLES.md, GUIDELINES.md
    - workflows/        SWE.md, meta-learning.md
    - templates/        PRD, architecture, ADR, roadmap, backlog, issues

--project installs to <path>/:
    - .claude/          settings.json with prompt-based hook examples
    - .serena/          project.yml (auto-detected languages, requires uvx)
    - docs/policy/      RULES.md, GUIDELINES.md templates
    - docs/knowledge/   README.md
    - reports/          analysis/, research/ directories

EOF
}

# Log functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    ((++WARNINGS))
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Create backup directory
create_backup_dir() {
    local target="$1"
    local backup_dir
    backup_dir="${target}/backups/$(date +%Y-%m-%d_%H-%M-%S)"
    mkdir -p "$backup_dir"
    echo "$backup_dir"
}

# Deep merge JSON files using jq
merge_json() {
    local source="$1"
    local target="$2"
    local backup_dir="$3"
    local rel_path="$4"

    if [ -f "$target" ]; then
        # Backup existing (preserve subfolder structure)
        local backup_file="${backup_dir}/${rel_path:-$(basename "$target")}"
        mkdir -p "$(dirname "$backup_file")"
        cp "$target" "$backup_file"
        ((++BACKUPS))

        # Deep merge: existing values take precedence, but add new keys
        if command -v jq &> /dev/null; then
            jq -s '.[0] * .[1]' "$target" "$source" > "${target}.tmp"
            mv "${target}.tmp" "$target"
            log_success "Patched: $target (backup: $backup_file)"
            ((++PATCHED))
        else
            log_warning "jq not found. Skipping JSON merge for $target"
            log_warning "Install jq for proper JSON merging: apt install jq / brew install jq"
        fi
    else
        mkdir -p "$(dirname "$target")"
        cp "$source" "$target"
        log_success "Created: $target"
        ((++CREATED))
    fi
}

# Copy markdown file (warn if different, overwrite with --overwrite)
copy_markdown() {
    local source="$1"
    local target="$2"
    local backup_dir="$3"
    local rel_path="$4"

    if [ -f "$target" ]; then
        if diff -q "$source" "$target" > /dev/null 2>&1; then
            log_info "Unchanged: $target"
            ((++UNCHANGED))
        elif [ "$OVERWRITE" = true ]; then
            # Backup existing to backup_dir (preserve subfolder structure)
            local backup_file="${backup_dir}/${rel_path:-$(basename "$target")}"
            mkdir -p "$(dirname "$backup_file")"
            cp "$target" "$backup_file"
            cp "$source" "$target"
            log_success "Overwritten: $target (backup: $backup_file)"
            ((++BACKUPS))
            ((++CREATED))
        else
            log_warning "$target exists and differs from SCZ version"
            log_warning "  Use --overwrite to replace (backup to backups/)"
        fi
    else
        mkdir -p "$(dirname "$target")"
        cp "$source" "$target"
        log_success "Created: $target"
        ((++CREATED))
    fi
}

# Copy shell script (backup + overwrite if different)
copy_script() {
    local source="$1"
    local target="$2"
    local backup_dir="$3"
    local rel_path="$4"

    if [ -f "$target" ]; then
        if diff -q "$source" "$target" > /dev/null 2>&1; then
            log_info "Unchanged: $target"
            ((++UNCHANGED))
            return
        fi
        # Backup existing (preserve subfolder structure)
        local backup_file="${backup_dir}/${rel_path:-$(basename "$target")}"
        mkdir -p "$(dirname "$backup_file")"
        cp "$target" "$backup_file"
        ((++BACKUPS))
        log_info "Backed up: $target → $backup_file"
    fi

    mkdir -p "$(dirname "$target")"
    cp "$source" "$target"
    chmod +x "$target"
    log_success "Installed: $target"
    ((++CREATED))
}

# Copy directory recursively with appropriate handling
copy_directory() {
    local source_dir="$1"
    local target_dir="$2"
    local backup_dir="$3"
    local component_name
    component_name="$(basename "$target_dir")"

    if [ ! -d "$source_dir" ]; then
        log_warning "Source directory not found: $source_dir"
        return
    fi

    mkdir -p "$target_dir"

    find "$source_dir" -type f | while read -r file; do
        local rel_path="${file#"$source_dir"/}"
        local target_file="${target_dir}/${rel_path}"
        local backup_rel_path="${component_name}/${rel_path}"
        local ext="${file##*.}"

        case "$ext" in
            json)
                merge_json "$file" "$target_file" "$backup_dir" "$backup_rel_path"
                ;;
            md)
                copy_markdown "$file" "$target_file" "$backup_dir" "$backup_rel_path"
                ;;
            sh)
                copy_script "$file" "$target_file" "$backup_dir" "$backup_rel_path"
                ;;
            *)
                # Default: copy if not exists
                if [ ! -f "$target_file" ]; then
                    mkdir -p "$(dirname "$target_file")"
                    cp "$file" "$target_file"
                    log_success "Created: $target_file"
                    ((++CREATED))
                else
                    log_info "Unchanged: $target_file"
                    ((++UNCHANGED))
                fi
                ;;
        esac
    done
}

# Install global components to ~/.claude/
install_global() {
    local target="${HOME}/.claude"
    log_info "Installing global components to $target"

    local backup_dir
    backup_dir=$(create_backup_dir "$target")

    # Install .claude/ contents (agents, skills, hooks)
    if [ -d "${SCRIPT_DIR}/.claude" ]; then
        copy_directory "${SCRIPT_DIR}/.claude/agents" "${target}/agents" "$backup_dir"
        copy_directory "${SCRIPT_DIR}/.claude/skills" "${target}/skills" "$backup_dir"
        copy_directory "${SCRIPT_DIR}/.claude/hooks" "${target}/hooks" "$backup_dir"
    fi

    # Install global/ contents (policy, workflows, templates, settings)
    if [ -d "${SCRIPT_DIR}/global" ]; then
        copy_directory "${SCRIPT_DIR}/global/policy" "${target}/policy" "$backup_dir"
        copy_directory "${SCRIPT_DIR}/global/workflows" "${target}/workflows" "$backup_dir"
        copy_directory "${SCRIPT_DIR}/global/templates" "${target}/templates" "$backup_dir"

        # Handle global settings.json
        if [ -f "${SCRIPT_DIR}/global/settings.json" ]; then
            merge_json "${SCRIPT_DIR}/global/settings.json" "${target}/settings.json" "$backup_dir"
        fi
    fi

    log_success "Global installation complete"
}

# Install project templates to specified path
install_project() {
    local target="$1"

    if [ -z "$target" ]; then
        log_error "Project path required for --project"
        usage
        exit 1
    fi

    log_info "Installing project templates to $target"

    local backup_dir
    backup_dir=$(create_backup_dir "$target")

    # Create project structure
    mkdir -p "${target}/docs/objectives"
    mkdir -p "${target}/docs/architecture"
    mkdir -p "${target}/docs/development"
    mkdir -p "${target}/docs/knowledge"
    mkdir -p "${target}/reports/analysis"
    mkdir -p "${target}/reports/research"

    # Install project/ contents if they exist
    if [ -d "${SCRIPT_DIR}/project" ]; then
        copy_directory "${SCRIPT_DIR}/project" "$target" "$backup_dir"
    fi

    # Initialize Serena project if uvx is available
    init_serena_project "$target"

    log_success "Project installation complete"
}

# Initialize Serena MCP project configuration
init_serena_project() {
    local target="$1"
    local project_name
    project_name="$(basename "$target")"

    # Skip if .serena/project.yml already exists
    if [ -f "${target}/.serena/project.yml" ]; then
        log_info "Serena project already configured: ${target}/.serena/project.yml"
        ((++UNCHANGED))
        return
    fi

    # Check if uvx is available
    if ! command -v uvx &> /dev/null; then
        log_warning "uvx not found. Skipping Serena project initialization."
        log_warning "  Install uv (https://docs.astral.sh/uv/) and run:"
        log_warning "  cd $target && uvx --from git+https://github.com/oraios/serena serena project create"
        return
    fi

    log_info "Initializing Serena project configuration..."

    # Create .serena directory
    mkdir -p "${target}/.serena"

    # Run serena project create (auto-detects languages)
    if (cd "$target" && uvx --from git+https://github.com/oraios/serena serena project create --name "$project_name" 2>/dev/null); then
        log_success "Created: ${target}/.serena/project.yml"
        ((++CREATED))
    else
        log_warning "Serena project creation failed. You can manually run:"
        log_warning "  cd $target && uvx --from git+https://github.com/oraios/serena serena project create"
    fi
}

# Print installation summary
print_summary() {
    echo ""
    echo "=================================="
    echo "SCZ Installation Summary"
    echo "=================================="
    echo -e "Created:    ${GREEN}${CREATED}${NC} files"
    echo -e "Patched:    ${BLUE}${PATCHED}${NC} files"
    echo -e "Unchanged:  ${UNCHANGED} files"
    echo -e "Warnings:   ${YELLOW}${WARNINGS}${NC} files"
    echo -e "Backups:    ${BACKUPS} files"
    echo ""

    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}Review warnings above for files that may need manual attention.${NC}"
        echo ""
    fi

    echo "Next steps:"
    echo "  1. Verify installation with 'ls ~/.claude/'"
    echo "  2. Test with '/orchestrate test project'"
    echo "  3. See README.md for usage guide"
}

# Find latest backup directory
find_latest_backup() {
    local target="$1"
    local backup_base="${target}/backups"

    if [ ! -d "$backup_base" ]; then
        echo ""
        return
    fi

    # Find most recent backup directory
    ls -1d "${backup_base}"/*/ 2>/dev/null | sort -r | head -1
}

# Restore settings.json from backup
restore_settings() {
    local target="$1"
    local backup_dir="$2"
    local settings_file="${target}/settings.json"

    if [ -z "$backup_dir" ]; then
        log_warning "No backup found to restore settings from"
        return
    fi

    # Look for settings.json in backup
    local backup_settings="${backup_dir}/settings.json"
    if [ -f "$backup_settings" ]; then
        cp "$backup_settings" "$settings_file"
        log_success "Restored: $settings_file from backup"
        ((++CREATED))
    else
        log_info "No settings.json backup found in $backup_dir"
    fi
}

# Cleanup global installation
cleanup_global() {
    local target="${HOME}/.claude"
    log_info "Cleaning up global installation from $target"

    local backup_dir
    backup_dir=$(find_latest_backup "$target")

    # Remove installed directories
    local dirs_to_remove=("agents" "skills" "hooks" "policy" "workflows" "templates")
    for dir in "${dirs_to_remove[@]}"; do
        if [ -d "${target:?}/${dir}" ]; then
            rm -rf "${target:?}/${dir}"
            log_success "Removed: ${target}/${dir}"
            ((++CREATED))
        fi
    done

    # Restore settings.json from backup
    restore_settings "$target" "$backup_dir"

    log_success "Global cleanup complete"
}

# Cleanup project installation
cleanup_project() {
    local target="$1"

    if [ -z "$target" ]; then
        log_error "Project path required for --cleanup with --project"
        usage
        exit 1
    fi

    log_info "Cleaning up project installation from $target"

    local backup_dir
    backup_dir=$(find_latest_backup "$target")

    # Remove installed directories
    local dirs_to_remove=(".claude" ".serena" "docs/knowledge" "reports/analysis" "reports/research")
    for dir in "${dirs_to_remove[@]}"; do
        if [ -d "${target:?}/${dir}" ]; then
            rm -rf "${target:?}/${dir}"
            log_success "Removed: ${target}/${dir}"
            ((++CREATED))
        fi
    done

    # Clean up empty parent directories
    rmdir "${target}/docs" 2>/dev/null || true
    rmdir "${target}/reports" 2>/dev/null || true

    # Restore settings if backup exists
    restore_settings "$target" "$backup_dir"

    log_success "Project cleanup complete"
}

# Main
main() {
    if [ $# -eq 0 ]; then
        usage
        exit 1
    fi

    local do_global=false
    local do_project=false
    local do_cleanup=false
    local project_path=""

    while [ $# -gt 0 ]; do
        case "$1" in
            --global)
                do_global=true
                shift
                ;;
            --project)
                do_project=true
                shift
                if [ $# -gt 0 ] && [[ ! "$1" =~ ^-- ]]; then
                    project_path="$1"
                    shift
                fi
                ;;
            --all)
                do_global=true
                do_project=true
                shift
                if [ $# -gt 0 ] && [[ ! "$1" =~ ^-- ]]; then
                    project_path="$1"
                    shift
                fi
                ;;
            --overwrite)
                OVERWRITE=true
                shift
                ;;
            --cleanup)
                do_cleanup=true
                shift
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
        esac
    done

    echo ""
    echo "SuperClaudeZero Installer v${VERSION}"
    echo "=================================="
    echo ""

    if [ "$do_cleanup" = true ]; then
        if [ "$do_global" = true ]; then
            cleanup_global
            echo ""
        fi
        if [ "$do_project" = true ]; then
            cleanup_project "$project_path"
            echo ""
        fi
        # If neither specified, default to global cleanup
        if [ "$do_global" = false ] && [ "$do_project" = false ]; then
            cleanup_global
            echo ""
        fi
    else
        if [ "$do_global" = true ]; then
            install_global
            echo ""
        fi

        if [ "$do_project" = true ]; then
            install_project "$project_path"
            echo ""
        fi
    fi

    print_summary
}

main "$@"
