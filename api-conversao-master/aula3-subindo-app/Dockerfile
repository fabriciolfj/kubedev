FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src
COPY ["src/PedeLogo.Catalogo.Api/PedeLogo.Catalogo.Api.csproj", "src/PedeLogo.Catalogo.Api/"]
RUN dotnet restore "src/PedeLogo.Catalogo.Api/PedeLogo.Catalogo.Api.csproj"
COPY ../aula2-kubernetes-namespaces .
WORKDIR "/src/src/PedeLogo.Catalogo.Api"
RUN dotnet build "PedeLogo.Catalogo.Api.csproj" -c Release -o /app/build

FROM build as publish
RUN dotnet publish "PedeLogo.Catalogo.Api.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS final
WORKDIR /app
EXPOSE 80
EXPOSE 443
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "PedeLogo.Catalogo.Api.dll"]