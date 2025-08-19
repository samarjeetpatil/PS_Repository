# Conditional Access ReportOnlyFailure Monitoring Script  

## 📌 Description  
This PowerShell script retrieves **Azure AD sign-in logs** where Conditional Access (CA) policies are in **Report-only Failure** state.  
It helps security and compliance teams to:  
- Monitor CA policies running in **report-only mode**  
- Identify **failed evaluations** of those policies  
- Export detailed results (user, app, IP, OS, CA policy, failure reason, etc.) to a CSV file  

The script is **interactive** – you provide the number of days to look back, and it generates a report.  

---

## ⚙️ Prerequisites  
- PowerShell 7.x or later  
- Microsoft Graph PowerShell SDK ([Installation Guide](https://learn.microsoft.com/en-us/powershell/microsoftgraph/installation))  
- Azure AD account with the following permissions:  
  - `Policy.Read.ConditionalAccess`  
  - `AuditLog.Read.All`  
  - `Directory.Read.All`  

---

## 🚀 Usage  

1. Clone this repository or download the script file.  
2. Open **PowerShell as Administrator**.  
3. Run the script:  
   ```powershell
   .\Get-CAReportOnlyFailures.ps1
   ```  
4. When prompted, enter the number of days to look back (e.g., `5`):  
   ```
   Enter number of days to look back: 5
   ```  
5. The script will connect to Microsoft Graph, fetch sign-in logs, and export results to:  
   ```
   CA_ReportOnlyFailures.csv
   ```

---

## 📊 Exported Report Fields  
- **PolicyName** – Name of CA policy applied  
- **AccessControls** – Grant controls enforced  
- **SessionControls** – Session controls applied  
- **User** – User display name  
- **UPN** – User principal name (login)  
- **AzureAppUsed** – Application accessed  
- **UserApp** – Client app used  
- **IP** – IP address of sign-in  
- **Result** – Sign-in result (e.g., Failure)  
- **Date** – Date and time of sign-in  
- **CAStatus** – Conditional Access status (`reportOnlyFailure`)  
- **IsInteractive** – Whether the sign-in was interactive  
- **OS** – Operating system  
- **Browser** – Browser used  
- **City / Country** – Sign-in location  
- **FailureReason** – Reason for CA evaluation failure  

---

## 🛠 How It Works  
1. Prompts for the number of days to fetch logs  
2. Connects to Microsoft Graph with required scopes  
3. Queries sign-in logs (`Get-MgAuditLogSignIn`) and filters only those with:  
   - `ConditionalAccessStatus = reportOnlyFailure`  
   - `CreatedDateTime > selected lookback date`  
4. Expands applied Conditional Access policies for each sign-in  
5. Builds a structured PowerShell object  
6. Exports results to CSV file for further analysis  

---

## 📌 Example Output (CSV Snippet)  
```csv
PolicyName,AccessControls,SessionControls,User,UPN,AzureAppUsed,UserApp,IP,Result,Date,CAStatus,IsInteractive,OS,Browser,City,Country,FailureReason
"Block Legacy Auth","MFA","",John Doe,john.doe@contoso.com,Office 365 Exchange Online,ActiveSync,192.168.1.10,Failure,2025-08-18T12:34:56Z,reportOnlyFailure,True,Windows 10,Outlook,"Mumbai","IN","Sign-in blocked by CA"
```
