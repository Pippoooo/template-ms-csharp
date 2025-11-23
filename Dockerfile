# syntax=docker/dockerfile:1



FROM mcr.microsoft.com/dotnet/sdk:10.0 AS development
RUN curl -sSL https://aka.ms/getvsdbgsh | sh /dev/stdin -v latest -l /vsdbg
WORKDIR /source/src/app/MS_NAME.Api
ENTRYPOINT ["dotnet", "watch", "--no-launch-profile"]



FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG TARGETARCH
COPY . /source
WORKDIR /source
RUN dotnet build --configuration Release 



FROM build AS unit-test
RUN dotnet test src/test/MS_NAME.Unit --configuration Release



FROM build AS integration-test
RUN dotnet test src/test/MS_NAME.Integration --configuration Release



FROM build AS publish
RUN dotnet publish src/app/MS_NAME.Api --self-contained -o /app --runtime linux-$TARGETARCH



FROM mcr.microsoft.com/dotnet/runtime-deps:10.0 AS release
WORKDIR /app

COPY --link --from=publish /app .

USER $APP_UID

ENTRYPOINT ["./MS_NAME.Api"]
