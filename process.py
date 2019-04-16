import json
import subprocess
import sys

# from pprint import pprint

input_file = sys.argv[1]

with open(input_file) as f:
    data = json.load(f)

    vmware_data = data['cloud']["vmware"]

    for vmware_data in vmware_data:
        vsphereip = vmware_data['vsphereip']
        vsphereuser = vmware_data['vsphereuser']
        vspherepassword = vmware_data['vspherepassword']
        GuestOsUser = vmware_data['GuestOsUser']
        GuestOsPassword = vmware_data['GuestOsPassword']

        for vm_data in vmware_data['vm']:
            print (vm_data['vmname'])
            vmname = vm_data['vmname']
            ovfpath = vm_data['ovfpath']

            bashCommand = 'pwsh ImportVM.ps1 -Server ' + vsphereip + ' -User ' + vsphereuser + ' -Password ' + vspherepassword + ' -Name ' + vmname + ' -Ovfpath ' + ovfpath + ' -GuestOsUser ' + GuestOsUser + ' GuestOsPassword ' + GuestOsPassword + ''

            process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
            output, error = process.communicate()

            print ("Vm Creation output: " + output)

            f.write(output)

        if error is not None:
            print ("error: " + error)
f.close()
