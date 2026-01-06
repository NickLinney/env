# ============================================================
# Base shell setup
# ============================================================

source ~/.profile

# ============================================================
# Ensure timesheets folder exists at shell startup
# ============================================================
mkdir -p ~/.timesheets

# ============================================================
# Workspace navigation
# ============================================================

alias ws='cd /Users/nrlin/Documents/Workspace'

# ============================================================
# Timeclock / Timesheet Management
# ============================================================
# Files:
#   ~/.timeclock      -> active timesheet (current session)
#   ~/.timesheets/    -> archived sessions
#
# Entry format:
#   Clocked in at  YYYY-MM-DD HH:MM
#   Clocked out at YYYY-MM-DD HH:MM
# ============================================================

# View current timesheet
timesheet() {
  if [[ -f ~/.timeclock ]]; then
    cat ~/.timeclock
  else
    echo "There is no current timesheet."
  fi
}

# List archived timesheets
alias timesheets='mkdir -p ~/.timesheets && ls -lah ~/.timesheets/'

# ----------------------------
# Clock in
# ----------------------------
# Prevents double-clockin.
# If already clocked in, prompts to close previous session or skip.
# ----------------------------
clockin() {
  local now now_epoch last_line last_time input seconds clockout_epoch clockout_time

  now="$(date +"%Y-%m-%d %H:%M")"
  now_epoch="$(date +%s)"

  # No active timesheet → simple clock-in
  if [[ ! -f ~/.timeclock ]]; then
    echo "Clocked in at $now"
    echo "Clocked in at $now" >> ~/.timeclock
    cd /Users/nrlin/Documents/Workspace
    return
  fi

  # Determine last entry
  last_line="$(tail -n 1 ~/.timeclock)"

  if [[ "$last_line" == Clocked\ in\ at* ]]; then
    last_time="${last_line#Clocked in at }"
    echo "You are already clocked in as of $last_time."
    echo -n "If you wish to start a new work session, enter the number of hours you worked last. ([0-99], 'q'uit, or 's'kip): "
    read input

    case "$input" in
      q|Q|quit|QUIT)
        echo "Aborted."
        return
        ;;
      s|S|skip|SKIP)
        echo "Starting new session without closing previous session."
        ;;
      *)
        # Validate numeric input: 0–99, up to 3 decimal places
        if [[ ! "$input" =~ ^([0-9]|[1-9][0-9])(\.[0-9]{1,3})?$ ]]; then
          echo "Invalid input. Must be a number between 0 and 99 with up to 3 decimal places."
          return 1
        fi

        # Convert hours → seconds
        seconds="$(printf "%.0f" "$(echo "$input * 3600" | bc -l)")"

        # Compute clockout time for the last clock-in
        clockout_epoch="$(( $(date -j -f "%Y-%m-%d %H:%M" "$last_time" +%s) + seconds ))"
        clockout_time="$(date -j -f "%s" "$clockout_epoch" +"%Y-%m-%d %H:%M")"

        # Close previous session
        echo "Clocked out at $clockout_time"
        echo "Clocked out at $clockout_time" >> ~/.timeclock
        ;;
    esac
  fi

  # Start new session
  echo "Clocked in at $now"
  echo "Clocked in at $now" >> ~/.timeclock
  cd /Users/nrlin/Documents/Workspace
}

# ----------------------------
# Clock out
# ----------------------------
# Prevents double-clockout.
# ----------------------------
clockout() {
  local now last_line last_time

  now="$(date +"%Y-%m-%d %H:%M")"

  # No active timesheet
  if [[ ! -f ~/.timeclock ]]; then
    echo "You are not clocked in."
    return
  fi

  last_line="$(tail -n 1 ~/.timeclock)"

  # Already clocked out
  if [[ "$last_line" == Clocked\ out\ at* ]]; then
    last_time="${last_line#Clocked out at }"
    echo "You are not clocked in. Your last clockout was at $last_time."
    return
  fi

  echo "Clocked out at $now"
  echo "Clocked out at $now" >> ~/.timeclock
}

# ----------------------------
# Close week (archive timesheet)
# ----------------------------
# Archives the current timesheet.
# If clocked in, prompts whether to clock out first.
#
# Options when prompted:
#   y → clock out, then archive
#   n → abort
#   s → skip clockout and archive anyway
# ----------------------------
clswk() {
  local last_line response archive_path

  if [[ ! -f ~/.timeclock ]]; then
    echo "There is no current timesheet to archive."
    return
  fi

  last_line="$(tail -n 1 ~/.timeclock)"

  # If currently clocked in
  if [[ "$last_line" == Clocked\ in\ at* ]]; then
    echo -n "You are clocked in. Clock out now? ('y'es, 'n'o, or 's'kip): "
    read response

    case "$response" in
      y|Y|yes|YES)
        clockout
        ;;
      n|N|no|NO)
        echo "Aborted."
        return
        ;;
      s|S|skip|SKIP)
        ;;
      *)
        echo "Invalid response. Aborted."
        return
        ;;
    esac
  fi

  mkdir -p ~/.timesheets
  archive_path="$HOME/.timesheets/TimeClock-$(date +%Y%m%d-%H%M%S).log"
  mv ~/.timeclock "$archive_path"

  echo "Timesheet archived to '$archive_path'."
}

# ----------------------------
# Timesheet comment
# ----------------------------
# Usage:
#   tscomm worked on API refactor
# ----------------------------
tscomm() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: tscomm <comment>"
    return 1
  fi

  # Ensure timesheet exists
  if [[ ! -f ~/.timeclock ]]; then
    touch ~/.timeclock
  fi

  echo "$*" >> ~/.timeclock
}

# ============================================================
# Development Tools
# ============================================================

# AWS profile switching
awsprofile() {
  export AWS_PROFILE="$1"
  echo "AWS_PROFILE is now set to '$AWS_PROFILE'"
}

# RepoMix (Docker-based)
alias repomix='docker run -v ${PWD}:/app -it --rm ghcr.io/yamadashy/repomix --style markdown'

# All Git Diffs on All Branches
alias diffs='git log --all --graph --patch --full-history'
