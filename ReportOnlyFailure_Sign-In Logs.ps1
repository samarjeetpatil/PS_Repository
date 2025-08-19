<#
================================================================================
 Script: Get ReportOnlyFailure Sign-In Logs for Conditional Access Policies
 Author: Samarjeet
================================================================================
#>

# Prompt for number of days
$Days = Read-Host "Enter number of days to look back"
if (-not [int]::TryParse($Days, [ref]0)) {
    Write-Host "Invalid input. Please enter a numeric value." -ForegroundColor Red
    exit
}

# Connect to Graph with required permissions
Connect-MgGraph -Scopes "Policy.Read.ConditionalAccess","AuditLog.Read.All","Directory.Read.All" -NoWelcome

# Set lookback date
$SetDate = (Get-Date).AddDays(-[int]$Days)

# Fetch Sign-In Logs with applied Conditional Access policies
$SignInLogs = Get-MgAuditLogSignIn -All | Where-Object {
    ($_.CreatedDateTime -gt $SetDate) -and
    ($_.ConditionalAccessStatus -eq "reportOnlyFailure")
}

$alluserhistory = @()

foreach ($resitem in $SignInLogs) {
    foreach ($policy in $resitem.appliedConditionalAccessPolicies) {
        $userhistory = [PSCustomObject]@{
            PolicyName      = $policy.DisplayName
            AccessControls  = ($policy.EnforcedGrantControls -join ', ')
            SessionControls = ($policy.EnforcedSessionControls -join ', ')
            User            = $resitem.userDisplayName
            UPN             = $resitem.userPrincipalName
            AzureAppUsed    = $resitem.appDisplayName
            UserApp         = $resitem.clientAppUsed
            IP              = $resitem.ipAddress
            Result          = $resitem.Result
            Date            = $resitem.CreatedDateTime
            CAStatus        = $resitem.ConditionalAccessStatus
            IsInteractive   = $resitem.IsInteractive
            OS              = $resitem.deviceDetail.operatingSystem
            Browser         = $resitem.deviceDetail.browser
            City            = $resitem.location.city
            Country         = $resitem.location.countryOrRegion
            FailureReason   = $resitem.Status.FailureReason
        }
        $alluserhistory += $userhistory
    }
}

# Export results to CSV
$OutputFile = ".\CA_ReportOnlyFailures.csv"
$alluserhistory | Export-Csv -Path $OutputFile -NoTypeInformation -Encoding UTF8

Write-Host "Report generated: $OutputFile" -ForegroundColor Green
