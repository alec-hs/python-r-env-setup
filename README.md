# Python & R Development Environment usinf Anaconda

Repo to setup Python and R environments and commons tools needed.

1. Open Powershell on target machine
2. Enable running scripts

    ```powershell
      Set-ExecutionPolicy Bypass -Scope Process
    ```

3. Download the script and run it

    ```powershell
      Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/alec-hs/python-r-env-setup/main/setup.ps1'))
    ```
