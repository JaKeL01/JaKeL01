function Install-Creo() {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateScript({ $_ -match '\d.\d.\d.\d' })]
        [string]
        $CreoVersion,

        [Parameter(Mandatory=$true)]
        [string[]]
        $ServerList,

        [Parameter()]
        [pscredential]
        $Credential
    )

    Begin {
        $sessionParams = @{
            ComputerName = $ServerList
            Authentication = "Credssp"
        }

        # Use PsCredentials (if provided), otherwise assume integrated auth
        if ($Credential) {
            $sessionParams.Add('Credential', $Credential)
        } else {
            Write-Information "Using integrated auth for [${env:USERNAME}]"
        }

        # Create remote PsSession(s) using available credentials
        $sessions = New-PSSession @sessionParams -ErrorAction Stop

        # Define the script that will be run on the remote server(s)
        $script = {
            param (
                [string]$CreoVersion
            )

            $installSource = "\\dbmg0162\transfer\CreoInstalls"
            & "${installSource}\MED-100WIN-CD-430_$($CreoVersion -replace '.','-')_Win64\setup.exe" -xml "${installSource}\xml\creobase.p.xml" -xml "${installSource}\xml\pma.p.xml"

            Get-ChildItem -Path "${installSource}\Global license" -Filter *.psf | Copy-Item -Destination "C:\Program Files\PTC\Creo ${CreoVersion}\Parametric\bin\" -Force

            Get-Item -Path "C:\Users\Public\Desktop\Creo Modelcheck*.lnk" | Remove-Item -Force

            Copy-Item -Path "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\PTC\Creo Parametric ${CreoVersion}.lnk" `
                      -Destination "C:\Users\Public\Desktop\"
        }
    }

    Process {
        # Run script on remote computers in parallel and create a job queue, then wait for all of the jobs to complete
        $jobs = Invoke-Command -Session $sessions -ScriptBlock $script -AsJob -ErrorAction Continue
        $jobs | Wait-Job
    }

    End {
        # Return the completed job queue
        return $jobs
    }
}

### Calling the function
$Servers = @(
    "server1.domain.com",
    "server2.domain.com",
    "server3.domain.com",
    "server4.domain.com",
    "usermachine.domain.com"
)

$creds = Get-Credential

# PsRemoting may require setup on the target machines, domain level or both
# https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting?view=powershell-7.3
Install-Creo -CreoVersion '6.0.4.0' `
             -ServerList $Servers `
             -Credential $creds