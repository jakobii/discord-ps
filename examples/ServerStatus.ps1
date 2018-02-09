




# [Warning!] this is not ready yet. please dont use until this gets to Master
############################################################################################


Import-Module '..\discord.psm1'
function test-Forever([string]$server, [string]$webHook) {

    while ($true) {
        try {
            Test-Connection -Server $server -TimeToLive 255 -ErrorAction 'stop'
        }
        catch {

            $PSItem

            $dmParam = @{
                message = "**$server**`nFailed to Respond`n$(get-date)`n:exclamation::desktop:"
                url     = $webHook
            }
            
            Send-DiscordMessage @dmParam 
        }
        Write-Host 'looping again'
        Start-Sleep -Seconds 60
        
    }
}

test-Forever -Server 8.8.8.8 -webhook $url

