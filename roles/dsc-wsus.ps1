Param (
    [bool]$isVagrant=$true,
    [Parameter(Mandatory)][string]$computerName
)

Configuration WSUS {
    param 
    ( 
        $computerName='localhost'
    ) 

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName xComputerManagement
    Import-DscResource -ModuleName xNetworking -ModuleVersion '5.5.0.0'
    Import-DscResource -ModuleName xPendingReboot 

    Node $computerName {

        LocalConfigurationManager {
            ActionAfterReboot = 'ContinueConfiguration'            
            ConfigurationMode = 'ApplyOnly'            
            RebootNodeIfNeeded = $true
        }

        xComputer SetName {
            Name = $computerName
        }

        xPendingReboot Reboot1 {
            Name = "RebootAfterSetName"
            DependsOn = '[xComputer]SetName'
         }

         WindowsFeature WSUSInstall {
            Ensure = 'Present'
            Name = 'UpdateServices'
            DependsOn = '[xPendingReboot]RebootAfterSetName'
         }
    }
}

If (!($computerName)) {
    $computerName = $env:computername
}

$config = @{
    AllNodes = @(
        @{
            NodeName = $computerName
            PsDscAllowPlainTextPassword = $true
            psDscAllowDomainUser = $true
        }
    )
}

If ($isVagrant) {
    $domainName = 'vagrant.local'
    $nicAlias = 'Ethernet 2'
    $dnsServers = '192.168.56.11'
    $user = 'vagrant\administrator'
    $password = 'vagrant' | ConvertTo-SecureString -asPlainText -Force
    $domainCreds = New-Object `
        -TypeName System.Management.Automation.PSCredential($user, $password)
    $adfsSvcCreds = $domainCreds
    $certThumbprint = 'aaf05276096d7777260661388c10381834b371f0'
    $certPath = 'c:\vagrant\files\fs-vagrant-local.pfx' 
    $certPassword = New-Object `
        -TypeName System.Management.Automation.PSCredential('vagrant', $password)
    $federationServiceName = 'fs.vagrant.local'

}

$args = @{
    'computerName'=$computerName
}

ADFS @args

#Ensure LCM is set to continue configuration after reboot            
Set-DSCLocalConfigurationManager -Path .\ADFS -Verbose -Force       
            
#Apply the configuration
Start-DscConfiguration -Wait -Force -Path .\ADFS -Verbose


#Build ADFS Farm
Import-Module ADFS

Try {
    $farmStatus = Get-ADFSFarmInformation
} Catch {
    Install-AdfsFarm `
        -CertificateThumbprint $certThumbprint `
        -Credential $domainCreds `
        -FederationServiceName $federationServiceName `
        -FederationServiceDisplayName "Active Directory Federation Service" `
        -ServiceAccountCredential $adfsSvcCreds `
        -OverwriteConfiguration
}

. .\samanage-adfs-rely-party.ps1