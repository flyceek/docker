FROM microsoft/dotnet:2.1-sdk
MAINTAINER flyceek@gmail.com

RUN apt-get update && apt-get install -y \
    cmake llvm-3.9 \
    clang-3.9 \
    lldb-3.9 \
    liblldb-3.9-dev \
    libunwind8 \
    libunwind8-dev \
    gettext \
    libicu-dev \
    liblttng-ust-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    uuid-dev \
    libnuma-dev \
    libkrb5-dev \
    && cat << \EOF >> ~/.bash_profile
export PATH="$PATH:/root/.dotnet/tools"
EOF \
    && export PATH="$PATH:/root/.dotnet/tools" \
    && dotnet tool install -g dotnet-dump \
    && dotnet tool install -g dotnet-sos \
    && dotnet tool install -g dotnet-symbol \
    && cd ~/.dotnet/tools \
    && ./dotnet-sos install
    