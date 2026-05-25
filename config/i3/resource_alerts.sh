#!/usr/bin/env bash

set -u

CHECK_INTERVAL_SECONDS=30
COOLDOWN_SECONDS=300

BATTERY_LOW_THRESHOLD=20
BATTERY_CRITICAL_THRESHOLD=10
TEMP_HIGH_THRESHOLD_C=85
TEMP_CRITICAL_THRESHOLD_C=95
CPU_HIGH_THRESHOLD_PERCENT=90
MEM_HIGH_THRESHOLD_PERCENT=90

STATE_DIR="${XDG_RUNTIME_DIR:-/tmp}"
STATE_FILE="${STATE_DIR}/resource_alerts.state"

notify() {
  local urgency="$1"
  local title="$2"
  local body="$3"
  notify-send -u "$urgency" "$title" "$body"
}

now_epoch() {
  date +%s
}

can_alert() {
  local key="$1"
  local now last
  now="$(now_epoch)"
  last=0

  if [[ -f "$STATE_FILE" ]]; then
    last="$(awk -F= -v k="$key" '$1 == k {print $2}' "$STATE_FILE" | tail -n1)"
    last="${last:-0}"
  fi

  ((now - last >= COOLDOWN_SECONDS))
}

mark_alert() {
  local key="$1"
  local now tmp
  now="$(now_epoch)"
  tmp="$(mktemp)"

  if [[ -f "$STATE_FILE" ]]; then
    awk -F= -v k="$key" '$1 != k {print $0}' "$STATE_FILE" >"$tmp"
  fi
  echo "${key}=${now}" >>"$tmp"
  mv "$tmp" "$STATE_FILE"
}

check_battery() {
  local battery_dir capacity status
  battery_dir="$(find /sys/class/power_supply -maxdepth 1 -type d -name 'BAT*' 2>/dev/null | head -n1)"
  [[ -z "$battery_dir" ]] && return

  capacity="$(cat "${battery_dir}/capacity" 2>/dev/null || true)"
  status="$(cat "${battery_dir}/status" 2>/dev/null || true)"
  [[ -z "$capacity" || -z "$status" ]] && return

  if [[ "$status" == "Discharging" && "$capacity" -le "$BATTERY_CRITICAL_THRESHOLD" ]]; then
    if can_alert "battery_critical"; then
      notify critical "Battery Critical" "Battery is at ${capacity}%. Plug in your charger now."
      mark_alert "battery_critical"
    fi
  elif [[ "$status" == "Discharging" && "$capacity" -le "$BATTERY_LOW_THRESHOLD" ]]; then
    if can_alert "battery_low"; then
      notify normal "Battery Low" "Battery is at ${capacity}%."
      mark_alert "battery_low"
    fi
  fi
}

read_max_temp_c() {
  local raw max=0 temp_c
  for file in /sys/class/thermal/thermal_zone*/temp; do
    [[ -f "$file" ]] || continue
    raw="$(cat "$file" 2>/dev/null || true)"
    [[ "$raw" =~ ^[0-9]+$ ]] || continue
    if ((raw > 1000)); then
      temp_c=$((raw / 1000))
    else
      temp_c=$raw
    fi
    ((temp_c > max)) && max="$temp_c"
  done
  echo "$max"
}

check_temperature() {
  local temp_c
  temp_c="$(read_max_temp_c)"
  ((temp_c <= 0)) && return

  if ((temp_c >= TEMP_CRITICAL_THRESHOLD_C)); then
    if can_alert "temp_critical"; then
      notify critical "Temperature Critical" "System temperature is ${temp_c}C."
      mark_alert "temp_critical"
    fi
  elif ((temp_c >= TEMP_HIGH_THRESHOLD_C)); then
    if can_alert "temp_high"; then
      notify normal "Temperature High" "System temperature is ${temp_c}C."
      mark_alert "temp_high"
    fi
  fi
}

read_cpu_usage_percent() {
  local cpu user nice system idle iowait irq softirq steal total busy
  read -r cpu user nice system idle iowait irq softirq steal _ _ </proc/stat
  total=$((user + nice + system + idle + iowait + irq + softirq + steal))
  busy=$((total - idle - iowait))
  echo "$total $busy"
}

check_cpu() {
  local total1 busy1 total2 busy2 dt db usage
  read -r total1 busy1 < <(read_cpu_usage_percent)
  sleep 1
  read -r total2 busy2 < <(read_cpu_usage_percent)

  dt=$((total2 - total1))
  db=$((busy2 - busy1))
  ((dt <= 0)) && return
  usage=$((db * 100 / dt))

  if ((usage >= CPU_HIGH_THRESHOLD_PERCENT)); then
    if can_alert "cpu_high"; then
      notify normal "CPU High Usage" "CPU usage is ${usage}%."
      mark_alert "cpu_high"
    fi
  fi
}

check_memory() {
  local total used usage
  total="$(awk '/MemTotal/ {print $2}' /proc/meminfo)"
  used="$(awk '/MemTotal/ {t=$2} /MemAvailable/ {a=$2} END {print t-a}' /proc/meminfo)"
  ((total <= 0)) && return
  usage=$((used * 100 / total))

  if ((usage >= MEM_HIGH_THRESHOLD_PERCENT)); then
    if can_alert "mem_high"; then
      notify normal "Memory High Usage" "Memory usage is ${usage}%."
      mark_alert "mem_high"
    fi
  fi
}

main() {
  touch "$STATE_FILE" 2>/dev/null || STATE_FILE="/tmp/resource_alerts.state"
  while true; do
    check_battery
    check_temperature
    check_cpu
    check_memory
    sleep "$CHECK_INTERVAL_SECONDS"
  done
}

main
