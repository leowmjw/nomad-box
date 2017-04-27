# On-going Powershell script to fully automate Consul, Nomad + Vault installation
# Still trying to figure out DNSMasq equivalet using the Module DNSServer
# Script porting over Worker Role from Bash ..
# Thanks to https://virtualbrakeman.wordpress.com/2016/03/20/powershell-could-not-create-ssltls-secure-channel/
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;

# Get Consul 
wget "https://releases.hashicorp.com/consul/0.8.1/consul_0.8.1_windows_amd64.zip?_ga=1.68195985.1073519233.1493040270" -OutFile consul.zip
Expand-Archive .\consul.zip

# Create the folders for Consul; needed?
cd consul
mkdir conf.d
cd conf.d
echo @"
{
    "addresses": {
        "http": "10.0.66.4"
    }
}
"@ >config.json
cd ..
# .\consul.exe agent -advertise="10.0.66.4" -bind="10.0.66.4" -data-dir="c:\temp\consul" -config-dir=".\conf.d" -retry-join="10.0.1.4" -retry-join="10.0.2.4" -retry-join="10.0.3.4"
# Get out from consul dir
cd ..

# Get Nomad
wget "https://releases.hashicorp.com/nomad/0.5.6/nomad_0.5.6_windows_amd64.zip" -OutFile nomad.zip
Expand-Archive .\nomad.zip
cd nomad
# Write the config.json file; this is hwo to do HERE strings in Powershell/Windows
echo @"
{
    "consul": {
        "address": "10.0.66.4:8500"
    },
    "addresses": {
        "http": "10.0.66.4"
    }
}
"@ >config.json

# Run Nomad; but how to foreground it? Unknown so don;t run first
# ./nomad agent -node-class=primary -client -servers="10.0.1.4,10.0.2.4,10.0.3.4" -data-dir="c:/temp/nomad" -config="./config.json"
# After foreground will need to find process and send it SIGHUP?

cd ..
# Get Git for Windows to have a sane; alternative is to enable Linux subssystem ..
# Not automated
wget "https://github.com/git-for-windows/git/releases/download/v2.12.2.windows.2/Git-2.12.2.2-64-bit.exe" -OutFile gitsetup.exe

# Thanks to https://sysnetdevops.com/2016/08/16/windows-subsystem-for-linux-wsl-setup-and-troubleshooting/
# Get-WindowsOptionalFeature -Online -FeatureName * | ? {$_.FeatureName -like "*subsystem*"}
# Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
# Above not needed; just get-module DNSServer should be fine ..

# Setup DNS? 
# Get-Module -Name DnsServer
# Use Acrylic Proxy for DNS; details below
# https://groups.google.com/forum/#!msg/consul-tool/HS_tnqYVms8/cmGTL-jnBwAJ
# Try using Choco
# https://chocolatey.org/packages/acrylic-dns-proxy
# Source: https://github.com/MatrixAI/Chocolatey-Acrylic-DNS-Proxy

