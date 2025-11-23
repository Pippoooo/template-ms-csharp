Param()
Write-Host "==> init-git.ps1: initializing a fresh local git repository"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Warning "git not found on PATH. Skipping git init."
    exit 0
}


# Try to init repo and set branch to main (git init -b main may not exist on older git)
$initOk = $false
try {
    git init -b main | Out-Null
    $initOk = $true
} catch {
    try {
        git init | Out-Null
        git branch -M main | Out-Null
        $initOk = $true
    } catch {
        Write-Warning "  git init failed: $_"
    }
}

if (-not $initOk) {
    Write-Warning "  unable to initialize git repository. Exiting script."
    exit 0
}

git add -A

# Try commit; if fails because of missing user.name/email, set local values and try again
$commitOk = $false
try {
    git commit -m "chore: initial commit from template" | Out-Null
    $commitOk = $true
} catch {
    Write-Host "  initial commit failed — configuring local user name/email and retrying"
    git config user.name "Template User"
    git config user.email "template@localhost"
    try {
        git commit -m "chore: initial commit from template" | Out-Null
        $commitOk = $true
    } catch {
        Write-Warning "  still unable to create commit: $_"
    }
}

if ($commitOk) {
    Write-Host "  initial commit created"
} else {
    Write-Warning "  leaving repo uncommitted"
}

Write-Host "==> git initialization complete"
