# Get all Key Vaults in the subscription
$KeyVaults = Get-AzKeyVault

# Define expiration period (12 months from today)
$ExpirationDate = (Get-Date).AddMonths(12)
$Today = Get-Date -Format yyyy-MM-dd

# Define additional tags
$Tag1Key = "maneesha"
$Tag1Value = "script"

$Tag2Key = "ExpirationSetDate"
$Tag2Value = $Today

# Iterate through each Key Vault
foreach ($vault in $KeyVaults) {
    $vaultName = $vault.VaultName
    Write-Host "Checking Key Vault: $vaultName"

    # Get all secrets in the Key Vault
    $Secrets = Get-AzKeyVaultSecret -VaultName $vaultName

    if ($Secrets.Count -eq 0) {
        Write-Host "No secrets found in Key Vault: $vaultName"
        continue
    }

    foreach ($secret in $Secrets) {
        $secretName = $secret.Name
        $secretDetails = Get-AzKeyVaultSecret -VaultName $vaultName -Name $secretName

        # Only update if the secret does NOT have an expiration date
        if ($null -eq $secretDetails.Expires) {
            Write-Host "Updating expiration for secret: $secretName in Key Vault: $vaultName"

            try {
                # Retrieve the existing secret value securely
                $SecretValueText = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto(
                    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secretDetails.SecretValue)
                )

                # Retrieve existing tags (if any) and add/update both tags
                $Tags = $secretDetails.Tags
                if (-not $Tags) {
                    $Tags = @{}
                }
                $Tags[$Tag1Key] = $Tag1Value
                $Tags[$Tag2Key] = $Tag2Value

                # Update the secret with an expiration date and new tags
                Set-AzKeyVaultSecret -VaultName $vaultName -Name $secretName `
                    -SecretValue (ConvertTo-SecureString -String $SecretValueText -AsPlainText -Force) `
                    -Expires $ExpirationDate -Tag $Tags

                Write-Host "Secret '$secretName' updated with expiration and tags."
            }
            catch {
                Write-Host "Error updating secret '$secretName' in Key Vault: $vaultName - $_" -ForegroundColor Red
            }
        }
        else {
            Write-Host "Secret '$secretName' already has an expiration date. Skipping update."
        }
    }
}

Write-Host "Script execution completed."
