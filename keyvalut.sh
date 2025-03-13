# Connect to Azure
Connect-AzAccount

# Get all Key Vaults in the subscription
$KeyVaults = Get-AzKeyVault

# Define expiration period (12 months from today)
$expirationDate = (Get-Date).AddMonths(12)
$today = Get-Date -Format "yyyy-MM-dd"

# Iterate through each Key Vault
foreach ($vault in $KeyVaults) {
    $vaultName = $vault.VaultName
    Write-Host "Checking Key Vault: $vaultName"

    # Get all secrets in the Key Vault
    $secrets = Get-AzKeyVaultSecret -VaultName $vaultName

    if ($secrets.Count -eq 0) {
        Write-Host "No secrets found in Key Vault: $vaultName"
        continue
    }

    foreach ($secret in $secrets) {
        $secretName = $secret.Name
        $secretDetails = Get-AzKeyVaultSecret -VaultName $vaultName -Name $secretName

        # Check if the secret has an expiration date
        if ($null -eq $secretDetails.Expires) {
            Write-Host "Updating expiration for secret: $secretName in Key Vault: $vaultName"

            try {
                # Retrieve the existing secret value securely
                $secretValueText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secretDetails.SecretValue)
                )

                # Retrieve existing tags (if any) and add/update the "ExpirationSetDate" tag
                $tags = $secretDetails.Tags
                if (-not $tags) {
                    $tags = @{}
                }
                $tags["ExpirationSetDate"] = $today

                # Update the secret with an expiration date and new tag
                Set-AzKeyVaultSecret -VaultName $vaultName -Name $secretName `
                    -SecretValue (ConvertTo-SecureString -String $secretValueText -AsPlainText -Force) `
                    -Expires $expirationDate -Tag $tags

                Write-Host "Secret '$secretName' updated with expiration and tag."
            }
            catch {
                Write-Host "Error updating secret '$secretName' in Key Vault: $vaultName - $_" -ForegroundColor Red
            }
        }
    }
}

Write-Host "Script execution completed."
