# discord-ps
#### Powershell cmdlets that make posting message to Discord EASY!


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

4) Use **Send-DiscordMessage** or its alias ***dm*** then check your Discord channel.
```powershell
$url = "YOUR_WEBHOOK_URL_HERE"

dm -l $url -m '*It* __works__  **!** :nerd::ok_hand:' 

dm -l $url -f 'PATH\TO\FILE.JPG'
```


## Goals

- ~~Send Message~~
- ~~Send File~~
- Message & File
- Create Webhook
- Get Webhook

## Use Case
An IT dept decides to use *Discord* instead of *Slack* becuase it has more group management features for free. The team has many powershell scripts running everywhere and would like to be notified of any abnormal status automatically. To save themselves a little time they could use this free module.


## Links

- [Discord Docs](https://discordapp.com/developers/docs/intro)

- [Discord Markdown](https://support.discordapp.com/hc/en-us/articles/210298617-Markdown-Text-101-Chat-Formatting-Bold-Italic-Underline-)