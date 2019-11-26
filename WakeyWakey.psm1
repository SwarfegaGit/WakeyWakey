function Start-WakeyWakey
{
    <#
        .Synopsis
            Keep the computer from sleeping and invoking screensavers or lock screens
        .DESCRIPTION
            Imitate key presses to prevent the computer from invoking idle tasks such as screensavers and locking the workstation
        .EXAMPLE
            Start-WakeyWakey -Minutes 10 -Frequency 5 -Key F15
            Imitate a F15 key press every 5 seconds for 10 minutes
        .EXAMPLE
            $TotalMinutes = New-TimeSpan -Start (Get-Date) -End (Get-Date).AddHours(10) | Select-Object -ExpandProperty TotalMinutes
            PS C:\> Start-WakeyWakey -Minutes $TotalMinutes
            
            Imitate a print screen key presses for the next 10 hours using the default frequency of 10 seconds
        .EXAMPLE
            Start-WakeyWakey -Minutes (New-TimeSpan -Start (Get-Date) -End (Get-Date).AddDays(5)).TotalMinutes
            Imitate a print screen key press for the next 5 days using the default frequency of 10 seconds
        .EXAMPLE
            Start-WakeyWakey -Minutes (New-TimeSpan -Start (Get-Date) -End (Get-Date -Hour 17 -Minute 00 -Second 00)).TotalMinutes -Key F15
            Imitate a F15 key press every 10 seconds until 17:00 (5PM)
    #>
    [CmdletBinding()]
    Param(
        [int]$Minutes = 60,
        [int]$Frequency = 10,
        [ValidateSet('PRTSC','F15')]
        [string]$Key = 'PRTSC',
        [switch]$HideProgress
    )

    Begin {

        [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
        $Shell = New-Object -ComObject Wscript.Shell
        $StartDateTime = Get-Date

        $KeyOption = switch ($Key) {
            PRTSC { '{PRTSC}' }
            F15 { '{F15}{F15}' }
        }

        Write-Host -Object "`n`n`n`n`n`n`nKeeping awake for '$Minutes' minutes with a '$Key' key press every '$Frequency' seconds" -ForegroundColor Green
        Write-Host -Object "Scheduled end time: $((Get-Date).AddMinutes($Minutes) | Get-Date -Format (Get-Culture).DateTimeFormat.FullDateTimePattern)" -ForegroundColor Green
        Write-Host -Object "Press 'Ctrl + C' to stop" -ForegroundColor Green
        
    }

    Process {

        for ($i = 0; (New-TimeSpan -Start $StartDateTime -End (Get-Date) | Select-Object -ExpandProperty TotalMinutes) -le $Minutes; $i++) {

            If (-NOT($HideProgress)) {
                $TotalSeconds = New-TimeSpan -Start $StartDateTime -End (Get-Date) | Select-Object -ExpandProperty TotalSeconds
                $Progress = $TotalSeconds/60/$Minutes*100
                If ($Progress -lt '50') {
                    Write-Progress -Activity 'Wakey wakey...' -Status "Progress: $([math]::Round($Progress)) %" -PercentComplete $Progress
                } Else {
                    Write-Progress -Activity 'Eggs and bakey...' -Status "Progress: $([math]::Round($Progress)) %" -PercentComplete $Progress
                }
                
                
            }
            
            Start-Sleep -Seconds $Frequency
            $Shell.SendKeys($KeyOption)
            
        }

    }

    End {
    }

}