FROM microsoft/dotnet:sdk AS build-env
ENV COMPlus_PerfMapEnabled=1
ENV COMPlus_EnableEventLog=1
ENV COMPlus_ZapDisable=1

WORKDIR /app

# Copy csproj and restore as distinct layers
# TODO wait for add RuntimeIdentifiers
# https://github.com/blogifierdotnet/Blogifier/pull/137
RUN git clone https://github.com/Slach/Blogifier .
#RUN git clone https://github.com/blogifierdotnet/Blogifier .
RUN dotnet build -r linux-x64 Blogifier.sln
#RUN dotnet build /p:UseAppHost=true /p:RuntimeIdentifier=linux-x64 Blogifier.sln

# Copy everything else and build
RUN mkdir /app/out
RUN dotnet publish --self-contained -r linux-x64 -o /app/out

# Build runtime image
FROM microsoft/dotnet:aspnetcore-runtime
ENV COMPlus_PerfMapEnabled=1
ENV COMPlus_EnableEventLog=1
ENV COMPlus_ZapDisable=1
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y linux-perf linux-tools procps sudo git lttng-tools lttng-modules-dkms liblttng-ust-dev
RUN git clone https://github.com/brendangregg/FlameGraph.git /opt/FlameGraph
RUN mkdir -p /opt/perfcollect/ \
    && curl -sL -o /opt/perfcollect/perfcollect http://aka.ms/perfcollect \
    && chmod +x /opt/perfcollect/perfcollect \
    && /opt/perfcollect/perfcollect install
WORKDIR /app/out
COPY --from=build-env /app/out .
CMD dotnet App.dll