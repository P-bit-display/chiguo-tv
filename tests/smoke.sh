#!/usr/bin/env bash
# Offline behavioral checks. No TV or network connection is made.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TASK_TMP="$(mktemp -d)"
trap 'rm -rf "$TASK_TMP"' EXIT
export MOCK_LOG="$TASK_TMP/adb.log" MOCK_CURL_LOG="$TASK_TMP/curl.log"
mkdir -p "$TASK_TMP/bin"
cat > "$TASK_TMP/bin/adb" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$MOCK_LOG"
if [ "${1:-}" = '-s' ]; then shift 2; fi
case "$*" in
    'connect '*) echo connected ;;
    devices) printf 'List of devices attached\n192.0.2.10:5555\tdevice\n' ;;
    'shell settings get secure enabled_accessibility_services')
        if [ "${MOCK_READ_FAIL:-0}" = 1 ]; then exit 1; fi
        printf '%s\r\n' "${MOCK_SERVICES:-com.xiaomi.voicecontrol/VoiceService}" ;;
    'shell dumpsys accessibility')
        if [ "${MOCK_BOUND:-1}" = 1 ]; then echo 'Service[label=Projectivy Launcher, component=test]'; fi ;;
    'shell getprop ro.build.version.sdk') echo 28 ;;
    'shell getprop ro.build.version.release') echo 9 ;;
    'shell getprop '*) echo MiTV-Test ;;
    'shell df -k /data') printf 'Filesystem 1K-blocks Used Available Use%% Mounted\n/dev/test 2000000 500000 1500000 25%% /data\n' ;;
    'shell pm path '*) echo package:/data/app/test/base.apk ;;
    'install '*) echo Success ;;
    'shell am start -W '*)
        if [ "${MOCK_LAUNCH_FAIL:-0}" = 1 ]; then echo 'Error: Activity does not exist'; else echo 'Status: ok'; fi ;;
    'shell cmd package set-home-activity '*)
        if [ "${MOCK_HOME_FAIL:-0}" = 1 ]; then echo 'Error: rejected'; else echo Success; fi ;;
    'shell pm list packages') printf 'package:com.V2.blb5\npackage:com.spocky.projengmenu\n' ;;
esac
exit 0
MOCK
cat > "$TASK_TMP/bin/curl" <<'MOCK'
#!/usr/bin/env bash
printf '%s\n' "$@" >> "$MOCK_CURL_LOG"
if [ "${MOCK_HTTP_FAIL:-0}" = 1 ]; then exit 22; fi
printf ok
MOCK
chmod +x "$TASK_TMP/bin/adb" "$TASK_TMP/bin/curl"
export CHIGUO_ADB_BIN="$TASK_TMP/bin/adb"
export PATH="$TASK_TMP/bin:$PATH"
PROJ='com.spocky.projengmenu/com.spocky.projengmenu.services.ProjectivyAccessibilityService'
VOICE='com.xiaomi.voicecontrol/VoiceService'
run_helper() { bash "$ROOT/tv_helper.sh" 192.0.2.10 "$@" > "$TASK_TMP/output" 2>&1; }
fail() { echo "FAIL: $*" >&2; exit 1; }
: > "$MOCK_LOG"
run_helper repair-launcher
grep -Fq "enabled_accessibility_services $VOICE:$PROJ" "$MOCK_LOG" || fail 'voice service was not preserved'
: > "$MOCK_LOG"
MOCK_SERVICES="$VOICE:$PROJ" run_helper repair-launcher
grep -Fq "enabled_accessibility_services $VOICE:$PROJ" "$MOCK_LOG" || fail 'existing service list changed'
if grep -Fq "$PROJ:$PROJ" "$MOCK_LOG"; then fail 'duplicate service'; fi
: > "$MOCK_LOG"
MOCK_SERVICES=null run_helper repair-launcher
grep -Fq "enabled_accessibility_services $PROJ" "$MOCK_LOG" || fail 'null service list'
: > "$MOCK_LOG"
if MOCK_READ_FAIL=1 run_helper repair-launcher; then fail 'read failure accepted'; fi
if grep -Fq 'settings put' "$MOCK_LOG"; then fail 'write after failed read'; fi
if MOCK_BOUND=0 run_helper repair-launcher; then fail 'unbound service reported as success'; fi
: > "$MOCK_LOG"
URL='https://example.com/config.json?a=1&b=two%20words'
run_helper push-tvbox "$URL"
[ ! -s "$MOCK_LOG" ] || fail 'HTTP import unnecessarily contacted ADB'
grep -Fxq 'do=api' "$MOCK_CURL_LOG" || fail 'wrong TVBox action'
grep -Fxq "url=$URL" "$MOCK_CURL_LOG" || fail 'URL changed'
if MOCK_HTTP_FAIL=1 run_helper push-tvbox "$URL"; then fail 'HTTP failure accepted'; fi
if run_helper push-tvbox 'javascript:invalid'; then fail 'invalid scheme accepted'; fi
if run_helper nas; then fail 'implicit personal NAS address'; fi
# Rollback removes Projectivy only and keeps accessibility enabled for voice.
: > "$MOCK_LOG"
MOCK_SERVICES="$VOICE:$PROJ" bash "$ROOT/restore.sh" 192.0.2.10 > "$TASK_TMP/output" 2>&1
grep -Fq "enabled_accessibility_services $VOICE" "$MOCK_LOG" || fail 'rollback removed voice'
if grep -Fq 'accessibility_enabled 0' "$MOCK_LOG"; then fail 'rollback disabled voice accessibility'; fi
for services in "$PROJ" null; do
    : > "$MOCK_LOG"
    MOCK_SERVICES="$services" bash "$ROOT/restore.sh" 192.0.2.10 > "$TASK_TMP/output" 2>&1
    grep -Fq 'settings delete secure enabled_accessibility_services' "$MOCK_LOG" || fail 'empty rollback list was not deleted'
    grep -Fq 'accessibility_enabled 0' "$MOCK_LOG" || fail 'empty rollback accessibility was not disabled'
    if grep -Fq 'settings put secure enabled_accessibility_services' "$MOCK_LOG"; then fail 'empty remote argument written'; fi
done
# Exercise deployment safely in a temporary copy; the ADB mock records every operation.
mkdir -p "$TASK_TMP/deploy"
cp "$ROOT/deploy.sh" "$ROOT/tv_helper.sh" "$TASK_TMP/deploy/"
: > "$MOCK_LOG"
if MOCK_LAUNCH_FAIL=1 bash "$TASK_TMP/deploy/deploy.sh" 192.0.2.10 --lite > "$TASK_TMP/output" 2>&1; then fail 'launch error accepted'; fi
if grep -Fq 'disable-user --user 0 com.mitv.tvhome' "$MOCK_LOG"; then fail 'stock launcher disabled after launch error'; fi
: > "$MOCK_LOG"
if MOCK_HOME_FAIL=1 bash "$TASK_TMP/deploy/deploy.sh" 192.0.2.10 --lite > "$TASK_TMP/output" 2>&1; then fail 'Home assignment failure accepted'; fi
if grep -Fq 'disable-user --user 0 com.mitv.tvhome' "$MOCK_LOG"; then fail 'stock launcher disabled after Home failure'; fi
: > "$MOCK_LOG"
mkdir -p "$TASK_TMP/deploy/apks"
: > "$TASK_TMP/deploy/apks/BBLL.apk"
bash "$TASK_TMP/deploy/deploy.sh" 192.0.2.10 --lite > "$TASK_TMP/output" 2>&1
grep -Fq 'disable-user --user 0 com.mitv.tvhome' "$MOCK_LOG" || fail 'valid Home assignment did not proceed'
if grep -F 'install ' "$MOCK_LOG" | grep -Fq BBLL.apk; then fail 'legacy BBLL reinstalled over repaired variant'; fi
for script in deploy.sh tv_helper.sh restore.sh; do
    if bash "$ROOT/$script" > "$TASK_TMP/output" 2>&1; then fail "missing target accepted by $script"; fi
done
echo 'PASS: accessibility preservation, TVBox HTTP import, explicit targets, launcher failure gates, BBLL preservation'
