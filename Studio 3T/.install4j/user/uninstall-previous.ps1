try {
    $InstalledProducts = gwmi -Query "SELECT ProductCode FROM Win32_Property WHERE Property='UpgradeCode' AND Value='{D828090A-0329-491A-A4DA-A8608A5CD5BD}'"

    if (-not $InstalledProducts) {
        return 0
    }
    
    $exitCodes = @()
    foreach($product IN $InstalledProducts) {
        $productCode = $product["ProductCode"]

        $exitCodes += (Start-Process -FilePath "msiexec.exe" -ArgumentList "/x $productCode /passive" -Wait -Passthru).ExitCode
    }
    
    if (-not $exitCodes) {
        return 0
    }
    else {
        foreach($exitCode IN $exitCodes) {
            #An uninstall failed, return failure state
            if (-not $exitCode -eq 0) {
                return -1
            }
        }
        return 0
    }    
}
catch {
    return -1 #Handle as error in install4j
}