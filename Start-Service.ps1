# Start Prorgamm Loop
while ($true) {
    # Scrape Links
    Write-Host ("Scraping Links from Group ID '" + $env:POOL_ID + "'...") -ForegroundColor Blue
    try {
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $response = Invoke-RestMethod ("https://www.flickr.com/services/rest/?method=flickr.groups.pools.getPhotos&api_key=" + $env:FLICKR_API_KEY + "&group_id=" + $env:POOL_ID + "&format=rest&per_page=500&extras=url_o") -Method 'GET' -Headers $headers
        Write-Host ("Done! " + $response.rsp.photos.photo.count + " Links received") -ForegroundColor Green
    }
    catch {
        <#Do this if a terminating exception happens#>
    }
    Write-Host (" -> Done!") -ForegroundColor Green

    # Download Scraped Links
    Write-Host ("Downloading " + $response.rsp.photos.photo.count + " Images...") -ForegroundColor Blue
    $CounterFilteringPassed = 0
    $response.rsp.photos.photo | Where-Object {$null -ne $_.url_o} | ForEach-Object {   
        $ImageName = (($_.url_o).split("/")[-1])
        $ImagePath = ($PSScriptRoot + "/images/" + $ImageName )
        $CurrentItem = $_

        if ($env:FILTER_HORIZONTAL_IMAGES_ONLY -match "true") {
            # Filter: Horizontal images Only
            if ($_.width_o -le $_.height_o) {
                Write-Host (" -> Not considering Image " + $ImageName + " because it is not Horizontal (W:" + $_.width_o + " H:" + $_.height_o + ")") -ForegroundColor Yellow
                return
            }
        } 
        if ($env:FILTER_VERTICAL_IMAGES_ONLY -match "true") {  
            # Filter: Vertial Images Only
            if ($_.height_o -le $_.width_o) {
                Write-Host (" -> Not considering Image " + $ImageName + " because it is not Vertical (W:" + $_.width_o + " H:" + $_.height_o + ")") -ForegroundColor Yellow
                return
            }
        }
        if ($null -ne $env:FILTER_MIN_HEIGHT) {
            # Filter: Minimum Height
            if ($_.height_o -lt $env:FILTER_MIN_HEIGHT) {
                Write-Host (" -> Not considering Image " + $ImageName + " minimum height of " + $env:FILTER_MIN_HEIGHT + " not reached (W:" + $_.width_o + " H:" + $_.height_o + ")") -ForegroundColor Yellow
                return
            }
        } 
        if ($null -ne $env:FILTER_MIN_WIDTH) {
            # Filter: Minimum Width
            if ($_.width_o -lt $env:FILTER_MIN_WIDTH) {
                Write-Host (" -> Not considering Image " + $ImageName + " minimum width of " + $env:FILTER_MIN_WIDTH + " not reached (W:" + $_.width_o + " H:" + $_.height_o + ")") -ForegroundColor Yellow
                return
            }
        } 

        # Download Image
        if ((Test-Path -Path $ImagePath) -eq $false) {
            try {
                Invoke-WebRequest $_.url_o -OutFile $ImagePath 
            }
            catch {
                Write-Host ("Cloud not download Image " + $CurrentItem.url_o + " because: " + $_.Exception.Message)
                return
            }

            # Filter: Maximum Size MB
            if ($null -ne $env:FILTER_MAX_FILESIZE_MB) {
                $FileSizeLimitBytes = (1024 * 1024 * $env:FILTER_MAX_FILESIZE_MB)
                $FileSizeBytes = ((Get-ChildItem $ImagePath).Size)
                if ($FileSizeBytes -gt $FileSizeLimitBytes) {
                        Write-Host (" -> Not considering Image " + $ImageName + " because it exeedes the Min/Max Filesize of 0MB/" + $env:FILTER_MAX_FILESIZE_MB + "MB (is " + ([math]::Round(($FileSizeBytes / 1024 / 1024), 2)) + "MB)") -ForegroundColor Yellow
                        Remove-Item $ImagePath -Force
                        return
                }
            } 

            $CounterFilteringPassed = $CounterFilteringPassed + 1
        }    
    }
        
    # Filter end Message
    Write-Host (" -> Filtering Done! " + $CounterFilteringPassed + " of 500 Images Added (" + (Get-ChildItem ($PSScriptRoot + "/images/")).count + " Images Total in DB)")

    # Sleep
    Write-Host ("Starting to Sleep for " + $env:INTERVAL + " Minute(s)...")
    Start-Sleep -Seconds (60 * $env:INTERVAL)
    Write-Host (" -> Done!") -ForegroundColor Green
}
