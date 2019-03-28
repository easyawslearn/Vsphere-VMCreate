write-host "Connecting to vsphere Server "

$VphereIP = "10.1.1.1"
$Vuser = "admin"
$Vpass = "admin"

Connect-VIServer -Server $VphereIP -User $Vuser -Password $Vpass

$vmHost = Get-VMHost
$vmName = "Ubuntu-5"

write-host "Imprting vm $vmName"

$OvfPath = "/home/ubnutu.ovf"

Import-vApp -Source $OvfPath -VMHost $vmHost -Name $vmName
Start-VM -VM $vmName

if ($Result.ExitCode -eq 0)
{
    Get-VM (r) -Name $vmName | Select Name, @{N="IP";E={@($_.Guest.IPAddress)}}
}



