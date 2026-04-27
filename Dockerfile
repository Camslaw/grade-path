# Build stage
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG TARGETARCH
WORKDIR /source

# Copy project file first for better Docker layer caching
COPY --link GradePath/GradePath.csproj GradePath/
RUN dotnet restore GradePath/GradePath.csproj -a $TARGETARCH

# Copy source code and publish app
COPY --link . .

# Important for .NET 10 Blazor:
# Do not use --no-restore here, because it can cause missing static assets like _framework/blazor.web.js.
RUN dotnet publish GradePath/GradePath.csproj -a $TARGETARCH -o /app

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0
EXPOSE 8080
WORKDIR /app

COPY --link --from=build /app .

USER $APP_UID

ENTRYPOINT ["./GradePath"]