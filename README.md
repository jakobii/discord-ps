# discord-ps
#### Powershell cmdlets that make posting to Discord EASY!

___


## Getting Started
1) First you need to [create a webhook](https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks) in Discord. Take note of the *WEBHOOK URL*.

       
![WEBHOOK EXAMPLE](https://github.com/jakobii/discord-ps/blob/master/examples/pics/discordwebhookui.jpg?raw=true "WEBHOOK EXAMPLE")


2) Git clone this module into your working directory
```bash
git clone https://github.com/jakobii/discord-ps.git
```

3) Import the module in your powershell scripts
```powershell
Import-Module '.\discord-ps\discord.psm1'
```

4) Use **Send-DiscordMessage** or its alias ***dm***.
```powershell
$url = "YOUR_WEBHOOK_URL_HERE"

# Send a message
Send-DiscordMessage -URL $url -Message '*It* __works__  **!** :nerd::ok_hand:' 

# Send A File
Send-DiscordMessage -URL $url -File 'PATH\TO\YOUR.FILE'

# Shorthand
dm -l $url -m '*It* __works__  **!** :nerd::ok_hand:' 
dm -l $url -f 'PATH\TO\YOUR.FILE'
```

___
## Goals

- ~~Send Message~~
- ~~Send File~~
- Message & File
- Create Webhook
- Get Webhook

## Use Case
An IT Dept decides to use *Discord* instead of *Slack* becuase it has more group management features for free. The team has many powershell scripts running everywhere and would like to be notified of any abnormal status automatically. To save themselves a little time they could use this free module.


## Backticks & Code Blocks

Powershell uses the backtick [ **`** ] as an [escape character](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_special_characters). Markdown uses the backtick to create code blocks and syntax highlighting. To store a backtick as a string in powershell you need to escape it with another backtick like this [ **``** ]. So if you need to store three backticks in a string you need to write six backticks like this [ **``````** ].

Past this in a powershell terminal if its confusing. It will return valid markdown syntax.
```powershell
$MarkdownCodeBlock = "``````powershell`nFunction Foo(`$bar){`n    return [omg]::new(`$bar)`n}`n``````"
write-host $MarkdownCodeBlock -f 'yellow'
```


Backticks wont escape within single quotes.
```powershell
$blah = '```'
write-host $blah -f 'yellow'
```




## Links

- [Discord Docs](https://discordapp.com/developers/docs/intro)

- [Discord Markdown](https://support.discordapp.com/hc/en-us/articles/210298617-Markdown-Text-101-Chat-Formatting-Bold-Italic-Underline-)
- [PS Quote Rules](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_quoting_rules)

- [PS Special Chars](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_special_characters)