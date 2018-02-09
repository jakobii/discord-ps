<#


.SYNOPSIS

    Powershell cmdlets that make posting message to Discord EASY!


.DESCRIPTION

    -Provides Purpose build Functions

    -provides a Powershell class named 'Discord' which is the heart of this module. 


.EXAMPLE
     
    dm -m 'Playing with Powershell' -l 'https://discordapp.com/api/webhooks/<channel_id>/<token>'

.NOTES

    [VersGuid] ad21d43f-8c30-49d8-ac83-79434f201f4a

    [tested] Friday, February 9, 2018 2:51:19 PM

    [tester] Jacob Ochoa

    [Status] Stable


#>



function import-types{
    # classes and DLL are werid in Powershell
    # This feels super hacky but it works I guess...
    Add-Type -AssemblyName System.Web
    Add-Type -AssemblyName System.Net.Http
}


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
    hidden $response # Discord server response

    # Main Properties
    #####################
    [string]$url
    [string]$attachmentPath

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
            #$this.msgWin()
        }
        catch {
            $this.msgfail($PSItem)
        }
    }

    [void]postFile($path, $url) {
        
        # store
        # [fix] add path & url validation
        $this.attachmentPath = $path
        $this.url = $url

        # build
        $mType = [System.Web.MimeMapping]::GetMimeMapping($path)
        $httpClientHandler = New-Object System.Net.Http.HttpClientHandler
        $httpClient = New-Object System.Net.Http.Httpclient $httpClientHandler
        $packageFileStream = New-Object System.IO.FileStream @($path, [System.IO.FileMode]::Open)
        $HeaderValue = New-Object System.Net.Http.Headers.ContentDispositionHeaderValue "form-data"
        $HeaderValue.Name = "fileData"
        $HeaderValue.FileName = (Split-Path $path -leaf)
        $streamContent = New-Object System.Net.Http.StreamContent $packageFileStream
        $streamContent.Headers.ContentDisposition = $HeaderValue
        $streamContent.Headers.ContentType = New-Object System.Net.Http.Headers.MediaTypeHeaderValue $mType
        $fileContent = New-Object System.Net.Http.MultipartFormDataContent
        $fileContent.Add($streamContent)

        #send
        try {
            $this.response = $httpClient.PostAsync($url, $fileContent).Result
        }
        catch {}
        finally {
            $httpClient.Dispose()
            $this.response.Dispose()
        }

    }

    
    [void]postSimple($msg, $url) {
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
                #$this.msgWin()
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
    [void]msgWin($msgtype) {
        #[fix] enable on verbose param only. 
        function pop-s($m) {Write-Host $m -b 'green' -f 'black'}
        function pop-w($m) {Write-Host $m -f 'green'}    
        pop-s "`n Discord Success! `n"
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


}#END DISCORD CLASS













# DELIVERABLE FUNCTIONS 
#######################################################################################################################


function new-discordObject() {
    # Return Empty Object
    return [discord]::new()
}
Set-Alias -Value get-childitem -Name Discord
Export-ModuleMember -Function new-discordObject -Alias *


function Send-DiscordMessage {

    # CMDLET for Discord Webhooks
    # The Face of the [discord] class 
    ###################################

    param(

        # Message
        [parameter(Mandatory = $true, ParameterSetName = "msg")]
        [alias("m", "msg")]
        [string]$Message,

        # File
        [parameter(Mandatory = $true, ParameterSetName = "file")]
        [alias("f")]
        [string]$file,

        # Webhook URL
        [parameter(Mandatory = $true)]
        [alias('l', 'Webhook')]
        [string]$URL
    
    )

    # create a dicord object
    $discord = [discord]::new()
    

    # Send Message
    if ($PSCmdlet.ParameterSetName -eq "msg") {
        $discord.postSimple($Message, $URL)
    }

    # Send File
    if ($PSCmdlet.ParameterSetName -eq "file") {
        $discord.postFile($File, $URL)
    }

}

Set-Alias -Value Send-DiscordMessage -Name dm
Export-ModuleMember -Function Send-DiscordMessage -Alias dm
