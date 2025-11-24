Craete a simple nodejs express app that will have Camoufox browser that I can control via JS. NodeJS server should be able to receive REST API request of the URL to visit and respond with HTML content and list of redirects to reach the final page. Camoufox browser should be equipred anti-bot detetion and implement best stealth techniques to avoid bans. Fingerprints should be managed automatically. Any CloudFlare challenges should be solved automatically if they appear.


- pip install -U camoufox[geoip]
- camoufox fetch