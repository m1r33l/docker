FROM mcr.microsoft.com/windows/servercore/iis:windowsservercore-ltsc2019

WORKDIR /certs
COPY /certs .

WORKDIR /scripts
COPY /scripts .

WORKDIR /LogMonitor
COPY LogMonitorConfig.json .

SHELL ["powershell"] 
RUN /scripts/buildContainer.ps1

