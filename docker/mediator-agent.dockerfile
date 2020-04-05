FROM streetcred/dotnet-indy:1.14.2 AS base
WORKDIR /app

FROM streetcred/dotnet-indy:1.14.2 AS build
WORKDIR /src
COPY [".", "."]

WORKDIR /src/samples/dotnetMediator
RUN dotnet restore "dotnetMediator.csproj" \
    -s "https://api.nuget.org/v3/index.json"

COPY ["samples/dotnetMediator/", "."]
COPY ["docker/test_bcovrin_pool_genesis.txn", "./pool_genesis.txn"]
RUN dotnet build "dotnetMediator.csproj" -c Release -o /app

FROM build AS publish
RUN dotnet publish "dotnetMediator.csproj" -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .

ENTRYPOINT ["dotnet", "dotnetMediator.dll"]