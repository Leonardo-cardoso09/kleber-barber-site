$ErrorActionPreference = 'Stop'

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoRoot

Write-Host "[push-on-save] Verificando alterações..."
$changes = git status --porcelain
if (-not $changes) {
    Write-Host "[push-on-save] Nenhuma alteração para enviar."
    exit 0
}

Write-Host "[push-on-save] Alterações encontradas. Fazendo commit e push..."
git add .
$branch = git branch --show-current
if (-not $branch) {
    $branch = 'main'
}

$commitMessage = "Auto-save update"
try {
    git commit -m $commitMessage
} catch {
    Write-Host "[push-on-save] Commit falhou: $_"
    exit 1
}

try {
    git push origin $branch
} catch {
    Write-Host "[push-on-save] Push falhou: $_"
    exit 1
}

$remoteUrl = git remote get-url origin
if ($remoteUrl -match '^(?:git@github.com:|https://github.com/)([^/]+)/([^/.]+)(?:\.git)?$') {
    $user = $matches[1]
    $repo = $matches[2]
    $browserUrl = "https://github.com/$user/$repo"
    Write-Host "[push-on-save] Abrindo GitHub: $browserUrl"
    Start-Process $browserUrl
} else {
    Write-Host "[push-on-save] URL do remoto não reconhecida: $remoteUrl"
}
