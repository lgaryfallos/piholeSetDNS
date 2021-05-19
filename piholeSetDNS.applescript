
--
-- check for Pihole and set DNS if found
--
-- version 1.0 - 2021-05-18
--

set IP_address to ""
set thePing to ""

-- wait a bit for everything to get up and running
delay 5

-- check internet connectivity
try
	set thePing to do shell script "/sbin/ping -o -c 5 8.8.8.8"
on error
	display dialog "You are not connected to the Internet" buttons {"OK"} default button 1 giving up after 3
	-- exit
	error number -128
end try

--get currently connected SSID
set mySSID to do shell script "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print substr($0, index($0, $2))}'"

------------------------------------------------------
-- List of your WIFI SSIDs where you have Pi-hole installed
set apList to {"homeNetwork", "workNetwork", "otherNetwork"}
-- List of Pi-hole IP addresses on the respective SSIDs above
set piList to {"192.168.1.3", "192.168.1.10", "10.0.0.2"}
------------------------------------------------------

repeat with a from 1 to length of apList
	set wifiSSID to item a of apList
	set piip to item a of piList
	if mySSID is equal to wifiSSID then
		set IP_address to piip
	end if
end repeat

-- If we couldn't find a match we are not at a Pi-hole enabled network - let us know and exit
if IP_address is equal to "" then
	do shell script "networksetup -setdnsservers Wi-Fi 1.1.1.1 8.8.8.8"
	display dialog "No Pi-hole enabled service found... Set DNS to Google/Cloudflare." buttons {"OK"} default button 1 giving up after 3
	error number -128
end if

-- Check Pi-hole address for response. If true, set DNS to this IP, onError fallback to google/cloudflare DNS
try
	set ping to (do shell script "ping -c 2 " & IP_address)
	do shell script "networksetup -setdnsservers Wi-Fi " & IP_address
	display dialog "Connection Successful. Set DNS to Pi-hole IP: " & IP_address buttons {"OK"} default button 1 giving up after 3
on error
	do shell script "networksetup -setdnsservers Wi-Fi 1.1.1.1 8.8.8.8"
	-- if we get here, the ping failed
	display dialog "Conection failed. Host is down. Set DNS to Google/Cloudflare." buttons {"OK"} default button 1 giving up after 3
end try


