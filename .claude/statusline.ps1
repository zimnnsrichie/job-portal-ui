# Claude Code status line: model name + context usage progress bar
# Lives inside the job-portal-ui project (.claude/statusline.ps1) so it can be
# version-controlled and edited alongside the rest of the project tooling.
# PowerShell counterpart to statusline.sh.

$inputJson = [Console]::In.ReadToEnd()
$data = $inputJson | ConvertFrom-Json

$model = $data.model.display_name
if ([string]::IsNullOrEmpty($model)) { $model = "Claude" }

$used = $data.context_window.used_percentage

# ANSI colors, dimmed (ESC[2;...) to match the terminal's dimmed color scheme
$ESC = [char]27
$CYAN = "$ESC[2;36m"
$GREEN = "$ESC[2;32m"
$YELLOW = "$ESC[2;33m"
$RED = "$ESC[2;31m"
$GREY = "$ESC[2;37m"
$RESET = "$ESC[0m"

$output = "$CYAN$model$RESET"

if ($null -ne $used -and $used -ne "") {
    $usedInt = [math]::Round([double]$used)
    if ($usedInt -lt 0) { $usedInt = 0 }
    if ($usedInt -gt 100) { $usedInt = 100 }

    $barWidth = 10
    $filled = [math]::Floor($usedInt * $barWidth / 100)
    $empty = $barWidth - $filled

    if ($usedInt -ge 80) {
        $color = $RED
    } elseif ($usedInt -ge 50) {
        $color = $YELLOW
    } else {
        $color = $GREEN
    }

    $bar = ("$([char]0x2588)" * $filled) + ("$([char]0x2591)" * $empty)

    $output += " $GREY[$color$bar$GREY]$RESET $color$usedInt%$RESET"
} else {
    $output += " $GREY[no context data]$RESET"
}

Write-Output $output
