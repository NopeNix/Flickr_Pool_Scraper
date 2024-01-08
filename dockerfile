FROM mcr.microsoft.com/powershell:lts-7.2-alpine-3.17

RUN mkdir /data
RUN mkdir /data/images
COPY ./Start-Service.ps1 /data/Start-Service.ps1

CMD pwsh /data/Start-Service.ps1