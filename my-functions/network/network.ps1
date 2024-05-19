Set-StrictMode -Version Latest
 
function Send-MagicPacket(
    [Parameter(Mandatory = $true, HelpMessage = "MAC address of target machine to wake up")][string] $MacAddress,
    [Parameter(Mandatory = $true, HelpMessage = "IP address or hostname of target machine to wake up")][string]$HostName,
    [Parameter(Mandatory = $true, HelpMessage = "Port to send magic packet to on the target machine")][string]$Port
) {
    Write-Output "Sending magic packet to ${HostName}:$Port at $MacAddress" 
    try {         
        ## Create UDP client instance
        $UdpClient = New-Object Net.Sockets.UdpClient
 
        ## Create IP endpoints for each port
        $IPEndPoint = New-Object Net.IPEndPoint $HostName, $Port
 
        ## Construct physical address instance for the MAC address of the machine (string to byte array)
        $MAC = [Net.NetworkInformation.PhysicalAddress]::Parse($MacAddress.ToUpper())
 
        ## Construct the Magic Packet frame
        $Packet = [Byte[]](, 0xFF * 6) + ($MAC.GetAddressBytes() * 16)
 
        ## Broadcast UDP packets to the IP endpoint of the machine        
        $UdpClient.Send($Packet, $Packet.Length, $IPEndPoint) | Out-Null
        $UdpClient.Close()
    }
    catch {
        $UdpClient.Dispose()
        $Error | Write-Error;
    }
}