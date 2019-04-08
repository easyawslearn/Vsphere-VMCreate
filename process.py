import json
import subprocess
#from pprint import pprint

with open('data.json') as f:
    data = json.load(f)

    vmware_data = data['cloud']["vmware"]

    for vmware_data in vmware_data:
        vsphereip = vmware_data['vsphereip']
        vsphereuser = vmware_data['vsphereuser']
        vspherepassword = vmware_data['vspherepassword']



        for vm_data in vmware_data['vm']:
            print (vm_data['vmname'])
            vmname = vm_data['vmname']
            ovfpath = vm_data['ovfpath']

            bashCommand = 'pwsh ImportVM.ps1 -Server ' + vsphereip + ' -User ' + vsphereuser + ' -Password ' + vspherepassword + ' -Name ' + vmname + ' -Ovfpath ' + ovfpath + ''

            process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
            output, error = process.communicate()

            print ("output: " + output)

            if error is not None:
                print ("error: " + error)