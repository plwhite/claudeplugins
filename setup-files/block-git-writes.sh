#!/bin/bash
# PreToolUse hook for Bash: let Claude run read-only git commands, and block
# everything else, so git state changes stay with the developer.
#
# Two checks run over the command line:
#   1. A git invocation in command position (start of a command, after a
#      separator, environment assignments or a wrapper such as `sudo`) must use
#      a read-only subcommand from the allow-list below. Anything else,
#      including an unknown subcommand or alias, is blocked.
#   2. Any other `git <subcommand>` in the line (e.g. inside `bash -c "..."` or
#      after `xargs`) is blocked if the subcommand is not read-only and is a
#      known git command, so mentions such as `grep git file` still pass.
# Global options before the subcommand (-C <dir>, -c <k=v>, --no-pager, ...)
# are skipped, so `git -C dir commit` is caught too.

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Fast path: no git at all.
echo "$COMMAND" | grep -qE '(^|[^[:alnum:]_.-])git([^[:alnum:]_.-]|$)' || exit 0

# Subcommands that never change repository state.
READ_ONLY=" status diff log show blame annotate rev-parse ls-files ls-tree \
ls-remote grep describe shortlog cat-file rev-list show-ref merge-base \
name-rev whatchanged help version count-objects check-ignore check-attr \
for-each-ref diff-tree diff-files diff-index range-diff cherry var "

# Every other git command we know of; used by check 2 only.
KNOWN=" add am apply archive bisect branch bundle checkout cherry-pick citool \
clean clone commit config fetch filter-branch format-patch fsck gc gui init \
maintenance merge mergetool mv notes pull push range-diff rebase reflog \
remote repack replace request-pull reset restore revert rm send-email \
sparse-checkout stash submodule switch tag update-index update-ref \
symbolic-ref worktree prune write-tree commit-tree read-tree hash-object \
mktag mktree pack-refs unpack-objects checkout-index "

block() {
  echo "BLOCKED: '$COMMAND' — git write operations are reserved for the developer. Only read-only git commands are allowed." >&2
  exit 2
}

# is_read_only SUBCOMMAND ARGS...: succeed if this invocation cannot change
# repository state.
is_read_only() {
  local sub=$1; shift
  [[ $READ_ONLY == *" $sub "* ]] && return 0
  local a
  case $sub in
    branch|tag)
      # Listing only: no positional argument unless --list/-l is given, and no
      # flag that creates, deletes, renames or edits.
      local listing=0 positional=0 writes
      if [[ $sub == branch ]]; then
        writes=" -d -D --delete -m -M --move -c -C --copy -f --force -u --unset-upstream --edit-description --create-reflog --no-track "
      else
        writes=" -d --delete -a --annotate -s --sign -u --local-user -m --message -F --file -f --force -e --edit --create-reflog "
      fi
      for a in "$@"; do
        [[ $writes == *" ${a%%=*} "* ]] && return 1
        case $a in
          --set-upstream-to*|--track*) [[ $sub == branch ]] && return 1 ;;
          -l|--list|--contains*|--no-contains*|--merged*|--no-merged*|--points-at*|--sort*|--format*) listing=1 ;;
          -*) ;;
          *) positional=1 ;;
        esac
      done
      (( positional == 0 || listing == 1 )) ;;
    remote)
      # Bare or verbose listing, or the show/get-url subcommands.
      for a in "$@"; do
        case $a in
          -v|--verbose) ;;
          show|get-url) return 0 ;;
          *) return 1 ;;
        esac
      done
      return 0 ;;
    stash)
      [[ $1 == list || $1 == show ]] ;;
    worktree)
      [[ $1 == list ]] ;;
    submodule)
      [[ $1 == status || $1 == summary ]] ;;
    notes)
      [[ $1 == list || $1 == show ]] ;;
    reflog)
      [[ $# -eq 0 || $1 == show || $1 == -* ]] ;;
    config)
      for a in "$@"; do
        case $a in
          --get|--get-all|--get-regexp|--get-urlmatch|-l|--list) return 0 ;;
        esac
      done
      return 1 ;;
    *) return 1 ;;
  esac
}

# parse_git WORDS...: WORDS starts just after `git`. Skips global options and
# sets SUB and SUBARGS.
parse_git() {
  SUB=""; SUBARGS=()
  while (( $# )); do
    case $1 in
      -C|-c|--git-dir|--work-tree|--namespace|--exec-path|--config-env) shift; (( $# )) && shift ;;
      -*) shift ;;
      *) SUB=$1; shift; SUBARGS=("$@"); return ;;
    esac
  done
}

# Split into simple commands on ; & | ( ) ` $( and newlines, and drop quotes so
# the contents of `bash -c "..."` are scanned as words.
SEGMENTS=$(printf '%s\n' "$COMMAND" | sed -e 's/\$(/\n/g' -e 's/[;&|()`]/\n/g' -e "s/[\"']/ /g")

while IFS= read -r line; do
  read -ra words <<< "$line"
  (( ${#words[@]} )) || continue

  # Check 1: the command word itself.
  i=0
  while (( i < ${#words[@]} )); do
    w=${words[i]}
    if [[ $w == *=* && $w != -* ]] || [[ $w == sudo || $w == env || $w == command || $w == exec || $w == time || $w == nohup || $w == nice ]]; then
      (( i++ ))
    else
      break
    fi
  done
  if (( i < ${#words[@]} )) && [[ ${words[i]} == git || ${words[i]} == */git ]]; then
    parse_git "${words[@]:i+1}"
    if [[ -n $SUB ]]; then
      is_read_only "$SUB" "${SUBARGS[@]}" || block
    fi
  fi

  # Check 2: any other git invocation in the line.
  for (( j = 0; j < ${#words[@]}; j++ )); do
    (( j == i )) && continue
    [[ ${words[j]} == git || ${words[j]} == */git ]] || continue
    parse_git "${words[@]:j+1}"
    [[ -n $SUB && $KNOWN == *" $SUB "* ]] || continue
    is_read_only "$SUB" "${SUBARGS[@]}" || block
  done
done <<< "$SEGMENTS"

exit 0
