# Check if all phases in planning.db are complete
# Always exits 0 -- uses stdout for status reporting

param(
    [string]$DbPath = "planning.db"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

python "$ScriptDir\check_complete.py" $DbPath
exit 0
