Configuration PullServer {
    Param (
        [string]$computerName = 'localhost',
        [string]$pathToWwwroot = 'c:\inetpub\wwwroot'
    )

    Import-DscResource -ModuleName xPSDesiredStateConfiguration

    Node $computerName {

        WindowsFeature DSCService {
            Ensure = 'Present'
            Name = 'DSC-Service'
        }

        xDscWebService PullServer {
            Ensure = 'Present'
            EndpointName = 'DSCPullServer'
            Port = 8080
            PhysicalPath = "$pathToWwwroot\psdscpullserver"
            CertificateThumbPrint = 'AllowUnencryptedTraffic'
            ModulePath = 'c:\ProgramFiles\WindowsPowerShell\DscService\Modules'
            ConfigurationPath = 'c:\ProgramFiles\WindowsPowerShell\DscService\Configuration'
            State = 'Started'
            DependsOn = '[WindowsFeature]DSCService'
        }

        xDscWebService ComplianceServer {
            Ensure = 'Present'
            EndpointName = 'DSCComplianceServer'
            Port = 9080
            PhysicalPath = "$pathToWwwroot\DSCComplianceServer"
            CertificateThumbPrint = 'AllowUnencryptedTraffic'
            IsComplianceServer = $true
            State = 'Started'
            DependsOn = ('[WindowsFeature]DSCService', `
                '[xDscWebService]PullServer')
        }
    }
}

PullServer
Start-DscConfiguration -Wait -Force -Path .\PullServer -Verbose