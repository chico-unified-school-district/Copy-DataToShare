[cmdletbinding()]
param (
 [Parameter(Mandatory = $True)][string]$SQLServer,
 [Parameter(Mandatory = $True)][string]$SQLDatabase,
 [Parameter(Mandatory = $True)][System.Management.Automation.PSCredential]$SQLCredential,
 [Parameter(Mandatory = $False)][string]$SQLQueryFile,
 [Parameter(Mandatory = $False)][string]$SQLQueryStatement,
 [Parameter(Mandatory = $True)][string]$SharePath,
 [Parameter(Mandatory = $True)][System.Management.Automation.PSCredential]$ShareCredential,
 [Parameter(Mandatory = $True)][string]$ExportName,
 [Alias('wi')][switch]$WhatIf
)

function Get-Data ($params, $myFile) {
 process {
  Write-Host ('{0},{1}' -f $MyInvocation.MyCommand.Name, $myFile.Split('.')[0])
  New-SqlOperation @sqlParams
 }
}
# ==================== Main =====================
# Imported Functions
Import-Module -Name CommonScriptFunctions -Cmdlet New-SqlOperation, Show-BlockInfo
Import-Module -Name dbatools -Cmdlet Invoke-DbaQuery, Set-DbatoolsConfig, Connect-DbaInstance, Disconnect-DbaInstance

$outPath = '.\data\'

$fullExportPath = (Join-Path -Path $outPath -ChildPath $ExportName)

$query = if ($SQLQueryFile) { Get-Content -Path $SQLQueryFile -Raw }
elseif ($SQLQueryStatement) { $SQLQueryStatement }
else { throw 'Either SQLQueryFile or SQLQueryStatement must be provided.' }

$sqlParams = @{
 Server     = $SQLServer
 Database   = $SQLDatabase
 Credential = $SQLCredential
 Query      = $query
}

New-PSDrive -Name Exports -PSProvider FileSystem -Root $SharePath -Credential $ShareCredential -ErrorAction Stop

$fullExportPath = (Join-Path -Path 'Exports:' -ChildPath $ExportName)

Get-Data $sqlParams | Export-Csv -NoTypeInformation -Path $fullExportPath
$csvContent = Get-Content -Path $fullExportPath -Raw
# Remove double quotes from the CSV content
$csvContent = $csvContent.Replace('"', '')
Write-Host "Double quotes removed from '$fullExportPath'."
# Write the modified content back to the CSV file
Set-Content -Path $fullExportPath -Value $csvContent -Encoding UTF8

#cleanup
Remove-PSDrive -Name Exports -Confirm:$false