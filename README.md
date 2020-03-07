# NeostradaAPI
Neostrada API DynDNS


Powershell code to update dynamic dns for neostrada.nl api V2
It disables the aliad for curl in powershell as i do not get it to work with Invoke-RestMethod.

Also it sends an Telegram message via powershell to update on a ip change.
In my case i also had to close my vpn tool to get the correct external ip

Tips are welcome to improve.

Powershell code om je dns records te updaten via neostrada api v2.
Let-op het script verwijderd de alias voor curl welke nu gelinkt zit aan Invoke-RestMethod

Wanneer er een update beschrikbaar is verstuurd het script ook via de Telegram api een update via powershell.
In my geval moet ik ook mijn vpn tool afsluiten om zo echte externe ip adres te krijgen, en kan aangepast worden naar wens.