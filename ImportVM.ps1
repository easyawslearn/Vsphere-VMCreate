param($Server, $User, $Password, $Name, $Ovfpath, $GuestOsUser, $GuestOsPasswd)
write-host "Connecting to vsphere Server "
$FILE_NAME = "$Name.log"

function healthCheck
{
    $VMIP = (get-vm $Name).guest.IPAddress[0]
    if (!$VMIP)
    {
        write-host " WAITNING FOR IP ASSIGNMENT IP IS: $res $VMIP"
        sleep 5
        healthCheck
    }
    else
    {
        write-host "$res IP ASSIGNED TO VM"
        ping -c 2 $VMIP
        if (!$?)
        {
            echo "Error: Ping to Host"
            exit 1
        }
        Write-Log "ping -c 2 $VMIP"
        Write-Log "Health Check Pass and Details as below"
    }
}

function commandCheck
{
    if (!$?)
    {
        echo "Error : Command executed with error"
        exit 1
    }
}

function VMInfotoJson
{

    $json_file_name = "$Name.json"
    echo '{' > $json_file_name
    $PrivateIP = (get-vm $Name).guest.IPAddress[0]
    $PublicIP = (get-vm $Name).guest.IPAddress[2]
    echo "`"VMName`" : `"$Name`" ," >> $json_file_name
    echo "`"PrivateIp`" : `"$PrivateIP`" ," >> $json_file_name
    echo "`"PublicIP`"  : `"$PublicIP`"">> $json_file_name
    echo '}' >> $json_file_name
}

function CustomerInfoCheck
{
    $script =  @"
    cat "$FILE_NAME"
"@
    Invoke-VMScript -VM $Name -ScriptText $script -GuestUser $GuestOsUser -GuestPassword  $GuestOsPassword -ScriptType bash
}

function WriteCustomerData
{
    $VMUID = Get-VM $Name | %{(Get-View $_.Id).config.uuid}
    $script = @"
    sudo echo $VMUID >> "$FILE_NAME"
"@
    Invoke-VMScript -VM $Name -ScriptText $script -GuestUser $GuestOsUser -GuestPassword  $GuestOsPassword -ScriptType bash

}

function vmInfo
{
    write-host "$Name's Private IP is: " -NoNewline
    write-host (get-vm $Name).guest.IPAddress[0]
    write-host "$Name's Public IP is: " -NoNewline
    write-host (get-vm $Name).guest.IPAddress[2]
    write-host "$Name is " -NoNewline
    write-host (get-vm $Name).guest.State
    echo "VMName=$Name" >> $Name.output
    echo "PrivateIp=(get-vm $Name).guest.IPAddress[0]" >> $Name.output
    echo "PublicIP=(get-vm $Name).guest.IPAddress[2]" >> $Name.output

}

Connect-VIServer -Server $Server -User $User -Password $Password
commandCheck

$vmexist = (get-vm $Name)
if (!$?)
{
    echo "VM Already Exists"
    exit 0
}
else
{
    write-host "Importing vm $Name"

    Import-vApp -Source $Ovfpath -VMHost $Server -Name $Name
    commandCheck
    write-host "vm $Name imported sucessfully"

    write-host "Starting $Name"
    if (((get-vm $Name).Guest.State) -eq "Running")
    {
        write-Host "VM already running"
    }
    else
    {
        Start-VM -VM $Name
        commandCheck
        write-host "$Name VM has been Started"
    }

    healthCheck
    vmInfo
    VMInfotoJson
    WriteCustomerData
    CustomerInfoCheck
}




