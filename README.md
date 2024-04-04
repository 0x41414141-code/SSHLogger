# SSHLogger

This script is designed to analyze SSH log files and perform various tasks such as:

- Reading commands sent from IP addresses.
- Identifying failed logins on the server.
- Identifying successful logins on the server.
- Listing all SSH connections.
- Listing all SSH disconnections.
- Listing all sudo commands executed.

## Usage


   ```bash
   git clone https://github.com/0x41414141-code/SSHLogger.git
   sudo chmod +x script.sh
   sudo ./script.sh
   ```
## Future Enhancements

- **Advanced Filtering:** Implementing more advanced filtering options for log analysis, such as filtering by date range, user, or command.

- **Custom Log File Locations:** Adding support for specifying custom log file locations to analyze logs from different sources or locations.

- **Support for Additional Log Formats:** Adding support for more log formats and log sources, such as syslog or custom log formats.

- **Integration with External Services:** Integrating with external services for notifications, alerting, or further analysis, such as sending alerts to mail.

- **Expanded Log Analysis:** Including log analysis for additional services such as FTP, HTTP, and other network protocols.


Feel free to contribute by opening issues for bugs or feature requests, or by submitting pull requests with improvements!
