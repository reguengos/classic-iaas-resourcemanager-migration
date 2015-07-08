﻿function New-AvailabilitySetResource
{
    Param
    (
        $Name,
        $Location
    )

    $createProperties = [PSCustomObject] @{}

    $resource = New-ResourceTemplate -Type "Microsoft.Compute/availabilitySets" -Name $Name `
        -Location $Location -ApiVersion $Global:apiVersion -Properties $createProperties

    return $resource
 }

function New-VmResource 
{
    Param 
    (
        [Microsoft.WindowsAzure.Commands.ServiceManagement.Model.PersistentVMRoleContext]
        $VM,
        
        [PSCredential]
        $Credentials, 
        
        [string]
        $NetworkInterfaceName,

        [string]
        $DiskAction
    )

        # Find the VMs image on the catalog
    $imageName = $VM.VM.OSVirtualHardDisk.SourceImageName

    $vmImage = Azure\Get-AzureVMImage -ImageName $imageName -ErrorAction SilentlyContinue -ErrorVariable $lastError

    if (-not $vmImage)
    {
        $message = "VM Image {0} for VM {1} on service {3} cannot be found." -f $imageName, $Name, $imageName
        Write-Verbose $lastError
        throw $message
    }

    $vmStorageProfile = $null

    if ($DiskAction -eq "NewDisks")
    {
        $armImageReference = Get-AzureArmImageRef -Location $location -Image $vmImage
        $vmStorageProfile = New-VmStorageProfile -ArmImageReference $armImageReference -VM $VM -StorageAccountName $storageAccountName
    }

    if ($DiskAction -eq "KeepDisks")
    {
        $vmStorageProfile = New-VmStorageProfile -VM $VM -KeepDisks
    }

    if ($DiskAction -eq "CopyDisks")
    {
        $vmStorageProfile = New-VmStorageProfile -VM $VM -StorageAccountName $storageAccountName -CopyDisks
    }

    if ($vmStorageProfile -eq $null)
    {
        throw "Cannot build storage profile"
    }


}