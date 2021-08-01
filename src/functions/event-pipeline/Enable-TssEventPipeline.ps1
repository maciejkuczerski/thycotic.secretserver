function Enable-TssEventPipeline {
    <#
    .SYNOPSIS
    Enable an Event Pipeline of an Event Pipeline Policy

    .DESCRIPTION
    Enable an Event Pipeline of an Event Pipeline Policy

    .EXAMPLE
    $session = New-TssSession -SecretServer https://alpha -Credential $ssCred
    Enable-TssEventPipeline -TssSession $session -Id 43

    Enable Event Pipeline 43

    .LINK
    https://thycotic-ps.github.io/thycotic.secretserver/commands/event-pipeline/Enable-TssEventPipeline

    .LINK
    https://github.com/thycotic-ps/thycotic.secretserver/blob/main/src/functions/event-pipeline/Enable-TssEventPipeline.ps1

    .NOTES
    Requires TssSession object returned by New-TssSession
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        # TssSession object created by New-TssSession for authentication
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [Thycotic.PowerShell.Authentication.Session]
        $TssSession,

        # Event Pipeline ID to enable
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('EventPipelineId')]
        [int[]]
        $Id
    )
    begin {
        $tssParams = $PSBoundParameters
        $invokeParams = . $GetInvokeTssParams $TssSession
    }
    process {
        Write-Verbose "Provided command parameters: $(. $GetInvocation $PSCmdlet.MyInvocation)"
        if ($tssParams.ContainsKey('TssSession') -and $TssSession.IsValidSession()) {
            . $CheckVersion $TssSession '10.9.000000' $PSCmdlet.MyInvocation
            foreach ($pipeline in $Id) {
                $uri = $TssSession.ApiUrl, 'event-pipeline', $pipeline, 'activate' -join '/'
                $invokeParams.Uri = $uri
                $invokeParams.Method = 'PUT'

                $enablePipelineBody = @{ Activate = $true }
                $invokeParams.Body = $enablePipelineBody | ConvertTo-Json
                if ($PSCmdlet.ShouldProcess("description: $pipeline", "$($invokeParams.Method) $uri with: `n$($invokeParams.Body)")) {
                    Write-Verbose "$($invokeParams.Method) $uri with: `n$($invokeParams.Body)"
                    try {
                        $restResponse = . $InvokeApi @invokeParams
                    } catch {
                        Write-Warning 'Issue warning message'
                        $err = $_
                        . $ErrorHandling $err
                    }

                    if ($restResponse) {
                        Write-Verbose "Event Pipeline [$pipeline] enabled"
                    } else {
                        Write-Warning "Event Pipeline [$pipeline] not successfully enabled"
                    }
                }
            }
        } else {
            Write-Warning 'No valid session found'
        }
    }
}