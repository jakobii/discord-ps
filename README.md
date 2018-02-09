# discord-ps
#### Powershell cmdlets that make posting message to Discord EASY!


## Getting Started
1) First you need to [create a webhook](https://support.discordapp.com/hc/en-us/articles/228383668-Intro-to-Webhooks) in your Discord App


       
![Blah](https://github.com/jakobii/discord-ps/blob/master/examples/pics/discordwebhookui.jpg?raw=true "Dicord UI")


2) Git clone this module into your working directory
```bash
git clone https://github.com/jakobii/discord-ps.git
```


3) Import the module in your powershell scripts
```powershell
Import-Module '.\discord-ps\discord.psm1'
```


4) Use **send-simpleDiscordMeassage** or its alias ***dm*** to send a simple message to your Discord channel.
```powershell
dm -m "Yay!`n:ok_hand:" -l 'https://discordapp.com/api/webhooks/<channel_id>/<token>'
```


## Immediate Goals

The ability to POST:
- <strike>Simple Posts</strike>
- attachements
- rich text
- HTML *if possible*
- Create New Webhooks


The ability to GET:
- attachments
- user status



## Use Cases
An IT dept desides to use *Discord* instead of *Slack* becuase it has more group management features for free. The team has many powershell scripts running everywhere and would like to be notified of any abnormal status automatically. To save themselves a little time they could use this free module.



## links
[Discord Docs](https://discordapp.com/developers/docs/intro)