param(
    [int]$Port = 8024,
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

$resolvedRoot = (Resolve-Path -LiteralPath $Root).Path
$candidatePort = $Port

function Test-PortOpen {
    param([int]$PortToCheck)

    $client = [System.Net.Sockets.TcpClient]::new()
    try {
        $async = $client.BeginConnect("127.0.0.1", $PortToCheck, $null, $null)
        if (-not $async.AsyncWaitHandle.WaitOne(200)) {
            return $false
        }
        $client.EndConnect($async)
        return $true
    } catch {
        return $false
    } finally {
        $client.Close()
    }
}

while (Test-PortOpen -PortToCheck $candidatePort) {
    $candidatePort += 1
}

$process = Start-Process `
    -FilePath python `
    -ArgumentList @("-m", "http.server", "$candidatePort", "--bind", "127.0.0.1", "--directory", $resolvedRoot) `
    -PassThru `
    -WindowStyle Hidden

Start-Sleep -Milliseconds 600

[PSCustomObject]@{
    Port = $candidatePort
    Pid = $process.Id
    Root = $resolvedRoot
    BaseUrl = "http://127.0.0.1:$candidatePort/"
}
