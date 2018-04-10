Param (
    [string]$computerName = 'localhost',
    [string]$pathToWwwroot = 'c:\inetpub\wwwroot',
    [string]$certThumbprint,
    [string]$certPath,
    [string]$certPassword
)

Configuration PullServer {
    Param (
        [string]$computerName = 'localhost',
        [string]$pathToWwwroot = 'c:\inetpub\wwwroot',
        [string]$certThumbprint,
        [string]$certPath,
        [string]$certPassword
    )

    Import-DscResource -ModuleName xCertificate
    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node $computerName {

        If ($certThumbprint -ne $null `
            -and $certPath -ne $null `
            -and $certPassword -ne $null `
            -and !(Get-ChildItem CERT:/LocalMachine/My | ?{$_.thumbPrint -eq $certThumbprint})) {
            xPfxImport Cert {
                Thumbprint = $certThumbprint
                Path = $certPath
                Location  = 'LocalMachine'
                Store = 'My'
                Credential = $certPassword
                Exportable = $true
            }
         }

        WindowsFeature DSCService {
            Ensure = 'Present'
            Name = 'DSC-Service'
            DependsOn = '[xPfxImport]PsCert'
        }

        xDscWebService PSDSCPullServer {
            Ensure = 'Present'
            EndpointName = 'PSDSCPullServer'
            Port = 8080
            PhysicalPath = "$pathToWwwroot\psdscpullserver"
            CertificateThumbPrint = 'AllowUnencryptedTraffic'
            ModulePath = "$env:SystemDrive\ProgramFiles\WindowsPowerShell\DscService\Modules"
            ConfigurationPath = "$env:SystemDrive\ProgramFiles\WindowsPowerShell\DscService\Configuration"
            CertificateThumbPrint = $certificateThumbPrint
            State = 'Started'
            UseSecurityBestPractices = $false
            DependsOn = '[WindowsFeature]DSCService'
        }

    }
}

PullServer
Start-DscConfiguration -Wait -Force -Path .\PullServer -Verbose