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







function Invoke-MultipartFormDataUpload {
    [CmdletBinding()]
    PARAM
    (
        [string][parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$InFile,
        [string]$ContentType,
        [Uri][parameter(Mandatory = $true)][ValidateNotNullOrEmpty()]$Uri,
        [System.Management.Automation.PSCredential]$Credential
    )
    BEGIN {
        if (-not (Test-Path $InFile)) {
            $errorMessage = ("File {0} missing or unable to read." -f $InFile)
            $exception = New-Object System.Exception $errorMessage
            $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, 'MultipartFormDataUpload', ([System.Management.Automation.ErrorCategory]::InvalidArgument), $InFile
            $PSCmdlet.ThrowTerminatingError($errorRecord)
        }

        if (-not $ContentType) {
            Add-Type -AssemblyName System.Web

            $mimeType = [System.Web.MimeMapping]::GetMimeMapping($InFile)
            
            if ($mimeType) {
                $ContentType = $mimeType
            }
            else {
                $ContentType = "application/octet-stream"
            }
        }
    }
    PROCESS {
        Add-Type -AssemblyName System.Net.Http

        $httpClientHandler = New-Object System.Net.Http.HttpClientHandler

        if ($Credential) {
            $networkCredential = New-Object System.Net.NetworkCredential @($Credential.UserName, $Credential.Password)
            $httpClientHandler.Credentials = $networkCredential
        }

        $httpClient = New-Object System.Net.Http.Httpclient $httpClientHandler

        $packageFileStream = New-Object System.IO.FileStream @($InFile, [System.IO.FileMode]::Open)

        $contentDispositionHeaderValue = New-Object System.Net.Http.Headers.ContentDispositionHeaderValue "form-data"
        $contentDispositionHeaderValue.Name = "fileData"
        $contentDispositionHeaderValue.FileName = (Split-Path $InFile -leaf)
        $streamContent = New-Object System.Net.Http.StreamContent $packageFileStream
        $streamContent.Headers.ContentDisposition = $contentDispositionHeaderValue
        $streamContent.Headers.ContentType = New-Object System.Net.Http.Headers.MediaTypeHeaderValue $ContentType
        
        $content = New-Object System.Net.Http.MultipartFormDataContent
        $content.Add($streamContent)

        try {
            $response = $httpClient.PostAsync($Uri, $content).Result

            if (!$response.IsSuccessStatusCode) {
                $responseBody = $response.Content.ReadAsStringAsync().Result
                $errorMessage = "Status code {0}. Reason {1}. Server reported the following message: {2}." -f $response.StatusCode, $response.ReasonPhrase, $responseBody

                throw [System.Net.Http.HttpRequestException] $errorMessage
            }

            #return $response.Content.ReadAsStringAsync().Result
        }
        catch [Exception] {
            $PSCmdlet.ThrowTerminatingError($_)
        }
        finally {
            if ($null -ne $httpClient) {
                $httpClient.Dispose()
            }

            if ($null -ne $response) {
                $response.Dispose()
            }
        }
    }
    END { }
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
            $this.msgWin()
        }
        catch {
            $this.msgfail($PSItem)
        }
    }

    [void]postFile($path, $url) {
        $this.attachmentPath = $path
        $this.url = $url
        
        try {
            Invoke-MultipartFormDataUpload -InFile $this.attachmentPath -Uri $this.url
            $this.msgWin()
        }
        catch {
            #$this.msgfail($PSItem)
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
        pop-s "`n Nice! :D `n"
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
Set-Alias -Value get-childitem -Name Discord
Export-ModuleMember -Function new-discordObject -Alias *



function Send-DiscordMessage {
    # SIMPLE DISCORD POSTING 
    ## this is the most the simplest way to post to discord 
    param(

        #Message
        [parameter(Mandatory = $true, ParameterSetName = "msg")]
        [alias("m", "msg")]
        [string]$message,

        #File
        [parameter(Mandatory = $true, ParameterSetName = "file")]
        [alias("f")]
        [string]$file,

        #Webhook URL
        [parameter(Mandatory = $true)]
        [alias('l', 'webhook')]
        [string]$url
    
    )


    #create a dicord object
    $discord = [discord]::new()
    

    #Send Message
    if ($PSCmdlet.ParameterSetName -eq "msg") {
        $discord.postSimple($message, $url)
    }

    #Send File
    if ($PSCmdlet.ParameterSetName -eq "file") {
        $discord.postFile($file, $url)
    }

}
Set-Alias -Value Send-DiscordMessage -Name dm
Export-ModuleMember -Function Send-DiscordMessage -Alias dm
