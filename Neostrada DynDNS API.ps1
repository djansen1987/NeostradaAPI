###
### Created by Daniel Jansen
### https://github.com/djansen1987
### 
### test 

Start-Transcript -Path C:\temp\NeostradaAPi\log.log
Remove-Item alias:curl -ea SilentlyContinue

$TelegramToken = "" #telegram api token
$chatID = "" #telegram chat id
$NeostradaToken = "" #neostrada api token

$dns_id1 = 
$dns_id2 = 

$record_id1 = 
$record_id2 = 

# check if vpn app is running
$VPN = Get-Process -Name "surfshark" -ea SilentlyContinue

if ($VPN){
    write-host "Shutting down VPN Service"
    $VPN|Stop-Process -Force
    Get-Service -Name 'Surfshark Service' |Stop-Service
    Start-Sleep 5
}

$ip = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content # current IP

$params1 = @{
    Uri         = "https://api.neostrada.com/api/dns/$dns_id1"
    Headers     = @{ 'Authorization' = "Bearer $NeostradaToken" }
    Method      = 'get'
    ContentType = 'application/json'
}

$params2 = @{
    Uri         = "https://api.neostrada.com/api/dns/$dns_id2"
    Headers     = @{ 'Authorization' = "Bearer $NeostradaToken" }
    Method      = 'get'
    ContentType = 'application/json'
}


$data1 = Invoke-RestMethod @params1
$current1 = $data1.results |?{$_.id -like "*$record_id1"}

$data2 = Invoke-RestMethod @params2
$current2 = $data2.results |?{$_.id -like "*$record_id2"}

#if ip is different Change and send messange
if ($current1.content -ne $ip -or $current2.content -ne $ip){



    $a = @()

    $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name 'name' -Value $current2.name
    $item | Add-Member -type NoteProperty -Name 'type' -Value $current2.type
    $item | Add-Member -type NoteProperty -Name 'content' -Value $current2.content
    $item | Add-Member -type NoteProperty -Name 'ttl' -Value $current2.ttl


    $a += $item
    
    $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name 'name' -Value $current1.name
    $item | Add-Member -type NoteProperty -Name 'type' -Value $current1.type
    $item | Add-Member -type NoteProperty -Name 'content' -Value $current1.content
    $item | Add-Member -type NoteProperty -Name 'ttl' -Value $current1.ttl


    $a += $item

    $response = curl --request PATCH -sb -H "Accept:application/json" -H "Authorization:Bearer $NeostradaToken" --data $("record_id=$record_id2&content=$ip&prio=0&ttl=60") https://api.neostrada.com/api/dns/edit/$dns_id2 
    $response2 = curl --request PATCH -sb -H "Accept:application/json" -H "Authorization:Bearer $NeostradaToken" --data $("record_id=$record_id1&content=$ip&prio=0&ttl=60") https://api.neostrada.com/api/dns/edit/$dns_id1

    $response = $response |ConvertFrom-Json
    $response2 = $response2 |ConvertFrom-Json


    $b = @()

    $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name 'name' -Value $($response.results|?{$_.id -like "*$record_id2"}).name
    $item | Add-Member -type NoteProperty -Name 'type' -Value $($response.results|?{$_.id -like "*$record_id2"}).type
    $item | Add-Member -type NoteProperty -Name 'content' -Value $($response.results|?{$_.id -like "*$record_id2"}).content
    $item | Add-Member -type NoteProperty -Name 'ttl' -Value $($response.results|?{$_.id -like "*$record_id2"}).ttl

    $b += $item

    $item = New-Object PSObject
    $item | Add-Member -type NoteProperty -Name 'name' -Value $($response2.results|?{$_.id -like "*$record_id1"}).name
    $item | Add-Member -type NoteProperty -Name 'type' -Value $($response2.results|?{$_.id -like "*$record_id1"}).type
    $item | Add-Member -type NoteProperty -Name 'content' -Value $($response2.results|?{$_.id -like "*$record_id1"}).content
    $item | Add-Member -type NoteProperty -Name 'ttl' -Value $($response2.results|?{$_.id -like "*$record_id1"}).ttl

    $b += $item

$telegrambody =  @("
<pre>
Ip change detected, DNS records updated

old:

| Name                 |  Type |  Content      |  ttl |
|----------------------|-------|---------------|------|
| $($a[0].name)   |  $($a[0].type)    | $($a[0].content)  |  $($a[0].ttl)  |
| $($a[1].name)|  $($a[1].type)    | $($a[1].content)  |  $($a[1].ttl)  |

-------------------------------------------------------
-------------------------------------------------------

new:

| Name                 |  Type |  Content      |  ttl |
|----------------------|-------|---------------|------|
| $($b[0].name)   |  $($b[0].type)    | $($b[0].content) |  $($b[0].ttl)  |
| $($b[1].name)|  $($b[1].type)    | $($b[1].content) |  $($b[1].ttl)  |
</pre>

")
    $telegrambody
    if(!($TelegramToken)){
        $Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($TelegramToken)/sendMessage?chat_id=$($chatID)&text=$($telegrambody)&parse_mode=html" -ErrorAction SilentlyContinue
    }

}else{
    Write-Host "No ip change.Current ip: $ip"
}

if ($VPN){
    write-host "Starting UP VPN Service"
    Get-Service -Name 'Surfshark Service' |start-Service 
    & 'C:\Program Files (x86)\Surfshark\Surfshark.exe'
}
Stop-Transcript
break

## Run these one time

# get DNS_id's
$params = @{
    Uri         = 'https://api.neostrada.com/api/domains'
    Headers     = @{ 'Authorization' = "Bearer $NeostradaToken" }
    Method      = 'get'
    ContentType = 'application/json'
}


# remove alias and use native curl and not invoke-request (give error)
Remove-Item alias:curl
