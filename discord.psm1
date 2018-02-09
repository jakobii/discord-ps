<#


.SYNOPSIS

    Powershell cmdlets that make posting message to Discord EASY!


.DESCRIPTION

    -Provides Purpose build Functions

    -provides a Powershell class named 'Discord' which is the heart of this module. 


.EXAMPLE
     
    dm -m 'Playing with Powershell' -l 'https://discordapp.com/api/webhooks/<channel_id>/<token>'

.NOTES

    [VersGuid] 87471c2c-01b3-4c5e-b4da-1baac1aace99

    [tested] Thursday, February 8, 2018 2:57:33 PM

    [tester] Jacob Ochoa

    [Status] Stable

#>












# CLASSES 
#######################################################################################################################



class discord {
    
    # Utilities
    ###################

    [string]$restMethod # GET, POST ...
    [string]$message # this will get copied into '$content' property after its beens escaped and sanatized.
    hidden [string]$regxUrl = '(https://discordapp.com/api/webhooks/)(\d+)[/](\w+)'
    hidden [string]$baseUrl = 'https://discordapp.com/api/webhooks/'
    hidden [string]$webHookDocUrl = 'https://discordapp.com/developers/docs/resources/webhook'


    # Main Properties
    #####################
    [string]$url
    $name # the name of the channel
    $channel_id # ID in WEBHOOK
    $token # super long unique nums & letters at the end of the webhook url 
    $avatar # this is a int, not sure where to get this except through a get request
    $guild_id # ?
    $id #channel ID ???
    $content # the message that will be sent


    # Methods
    #######################

    [string]genJSON() {
        switch ($this.restMethod) {
            'POST' {
                $this.message = @{
                    name       = $this.name
                    channel_id = $this.channel_id 
                    token      = $this.token
                    avatar     = $this.avatar
                    guild_id   = $this.guild_id
                    id         = $this.id
                    content    = $this.content
                }
                break
            }
        }
        return ConvertTo-Json $this.message # [fix] 'Invoke-RestMethod' might do this automatically...
    }

    [string]genUrl() {
        #allows for creating URL 

        $this.url = $this.baseUrl
        $this.url += '/' + $this.channel_id
        $this.url += '/' + $this.token
        return $this.url
    }


    [void]post() {
        # A more complex way of posting messages.
        # Will Support Rich text and Stuff... not there yet though sorry.

        $restParam = @{
            Method      = $this.restMethod 
            Uri         = $this.url 
            Body        = $this.CreateJSON('POST') 
            ContentType = "application/json"
        }
        try {
            Invoke-RestMethod @restParam
            $this.msgWin()
        }
        catch {
            $this.msgfail($PSItem)
        }
    }

    
    [void]simplePost($msg, $url) {
        # the 'easy button', 'no nonesense'  method
        
        $this.content = $msg
        $this.url = $url
        if ($this.testUrl($url)) {
            $restParam = @{
                Method      = 'POST'
                Uri         = $url
                Body        = @{content = $msg}
                ErrorAction = 'stop'
            }
            try {
                Invoke-RestMethod @restParam
                $this.msgWin()
            }
            catch {
                $this.msgfail($PSItem)
            }
        }
    }


    ## diagnostic Methods
    ################################
    [bool]testUrl($u) {
        $reg = [regex]::new($this.regxUrl)
        $match = $reg.Match($u)
        if (!$match) {
            write-host 'Oops.. Please check the URL' -f red
        }
        
        return $match
    }
    [void]msgWin() {
        function pop-s($m) {Write-Host $m -b 'green' -f 'black'}
        function pop-w($m) {Write-Host $m -f 'green'}    
        pop-s "`n Nice! Message Sent Successfully. :D `n"
    }
    [void]msgfail($err) {
        function pop-e($m) {write-host $m -f 'red'-NoNewline}
        function pop-e2($m) {write-host $m -f 'white'}
        Write-Host " Oops! something Went Wrong... " -b 'red' -f 'white'
        pop-e 'Error Message: '
        pop-e2 $err.Exception.Message
        pop-e 'url: '
        pop-e2 $err.targetObject.RequestUri
        pop-e 'REST Method: '
        pop-e2 $err.Exception.Response.Method
    }
    [void]help() {
        Start-Process $this.webHookDocUrl
        write-host -F 'white' -b 'blue' -Object " Simple Examples "
        $Example = "`$discord = [discord]::new()`n`$discord.simplePost('Playing with Powershell','$($this.baseUrl)/<channel_id>/<token>')`n"
        write-host -Object $Example -f Magenta
    }


}#END DISCORD OBJECT
















# FUNCTIONS 
#######################################################################################################################

function new-discordObject() {
    # Return Empty Object
    return [discord]::new()
}
Export-ModuleMember -Function new-discordObject -Alias *
Set-Alias -Value get-childitem -Name Discord




function Send-DiscordMessage {
    # SIMPLE DISCORD POSTING 
    ## this is the most the simplest way to post to discord 
    param(
        #Message Content
        [parameter(Mandatory = $true)]
        [alias("m", "msg")]
        [string]$message,
    
        #Webhook URL
        [parameter(Mandatory = $true)]
        [alias('l', 'webhook')]
        [string]$url
    )
    #create a dicord object
    $discord = [discord]::new()
    
    # fill the object and send
    $discord.simplePost($message, $url)
}
Set-Alias -Value Send-DiscordMessage -Name dm
Export-ModuleMember -Function Send-DiscordMessage -Alias dm

