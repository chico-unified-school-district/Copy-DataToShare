# Copy-DataToShare.ps1

This PowerShell script exports data from a SQL Server database as a CSV file to a network share using provided credentials. It supports running a SQL query from a file or a direct statement.

## Prerequisites

- PowerShell 5.1 or later
- `dbatools` PowerShell module
- `CommonScriptFunctions` module (must provide `New-SqlOperation` and `Show-BlockInfo`)
- Access to the target SQL Server and network share

## Parameters

| Name                | Type                   | Required | Description                                   |
| ------------------- | ---------------------- | -------- | --------------------------------------------- |
| `SQLServer`         | `string`               | Yes      | SQL Server instance name or address           |
| `SQLDatabase`       | `string`               | Yes      | Name of the SQL database                      |
| `SQLCredential`     | `PSCredential`         | Yes      | Credential for SQL Server authentication      |
| `SQLQueryFile`      | `string`               | No       | Path to a file containing the SQL query       |
| `SQLQueryStatement` | `string`               | No       | SQL query statement as a string               |
| `SharePath`         | `string`               | Yes      | UNC path to the network share                 |
| `ShareCredential`   | `PSCredential`         | Yes      | Credential for accessing the network share    |
| `ExportName`        | `string`               | Yes      | Name of the exported CSV file                 |
| `WhatIf`            | `switch` (alias: `wi`) | No       | Simulate the operation without making changes |

**Note:** Either `SQLQueryFile` or `SQLQueryStatement` must be provided.

## Usage

```powershell
# Example usage
$SqlCred = Get-Credential
$ShareCred = Get-Credential

.\Copy-DataToShare.ps1 `
    -SQLServer "MyServer" `
    -SQLDatabase "MyDatabase" `
    -SQLCredential $SqlCred `
    -SQLQueryFile "query.sql" `
    -SharePath "\\server\share\folder" `
    -ShareCredential $ShareCred `
    -ExportName "ExportedData.csv"
```

## What It Does

1. Reads a SQL query from a file or direct input.
2. Executes the query against the specified SQL Server database.
3. Exports the result to the network share as a CSV file.
4. Removes double quotes from the CSV content.
5. Cleans up mapped drives.

## Notes

- Ensure you have the necessary permissions on both the SQL Server and the network share.
- The script removes double quotes from the CSV output for compatibility with certain downstream processes.
- The exported file is temporarily stored and then deleted after processing.

## License

MIT License or as specified by your organization.
