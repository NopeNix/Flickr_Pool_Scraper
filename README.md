# Flickr_Pool_Scraper
Scrape Flickr Pools (Docker Container) - with Filter Options 

## How To Use
You Provide a Flickr Pool ID (e.g. ```1629008@N24``` this can be found in the Pool URL e.g. https://www.flickr.com/groups/```1629008@N24```/) via a Docker Environment Varialbe and the Container will download up to 500 Pictures of this Pool and will update the collection every x Minutes (can be set by you) with the latest pictures.

## docker-compose Example
The Docker Compose Example should be self-explanatory.

**IMPORTANT: CHANGE FLICKR_API_KEY Variable before using!** 
```yml
version: "3"
services:
  flickr_pool_scraper:
    image: nopenix/flickr_pool_scraper
    restart: unless-stopped
    volumes:
      - /mount/where/you/want/images/to/be:/data/images/ # The container sotres the downloaded images under /data/images
    environment:
      - "POOL_ID=1629008@N24" # ID of the Pool to Scrape e.g. 1629008@N24
      - "FILTER_HORIZONTAL_IMAGES_ONLY=true" # Only Horizontal Images (true/false)
      - "FILTER_VERTICAL_IMAGES_ONLY=false" # Only Vertical Images (true/false)
      - "FILTER_MIN_HEIGHT=1080" # Minimum Image Height in Pixel
      - "FILTER_MIN_WIDTH=1920" # Minimum Image Height in Pixel
      - "FILTER_MAX_FILESIZE_MB=10" # Maximum Filesize in MB of a single Image
      - "INTERVAL=60" # Interval in Minutes between Scraper Runs
      - "FLICKR_API_KEY=CHANGE-ME!" # You need a Flickr API Key, get it at: https://www.flickr.com/services/api/misc.api_keys.html
```
