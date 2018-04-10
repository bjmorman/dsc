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
    $computerName = 'win2012-wsus-1'
}

$args = @{
    'computerName'=$computerName
}

WSUSADFS @args

#Ensure LCM is set to continue configuration after reboot            
Set-DSCLocalConfigurationManager -Path .\WSUS -Verbose -Force       
            
#Apply the configuration
Start-DscConfiguration -Wait -Force -Path .\WSUS -Verbose
