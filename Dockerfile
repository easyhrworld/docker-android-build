FROM ubuntu:17.10

ENV ANDROID_HOME="/opt/android-sdk" \
    ANDROID_NDK="/opt/android-ndk" \
    JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

# Get the latest version from https://developer.android.com/studio/index.html
ENV ANDROID_SDK_TOOLS_VERSION="4333796"

# Get the latest version from https://developer.android.com/ndk/downloads/index.html
ENV ANDROID_NDK_VERSION="17b"


# nodejs version (DO NOT CHANGE)
ENV NODE_VERSION="8.x"

# Set locale
ENV LANG="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" 

ENV DEBIAN_FRONTEND="noninteractive" \
    TERM=dumb \
    DEBIAN_FRONTEND=noninteractive

# Variables must be references after they are created
ENV ANDROID_SDK_HOME="$ANDROID_HOME"
ENV ANDROID_NDK_HOME="$ANDROID_NDK/android-ndk-r$ANDROID_NDK_VERSION"

ENV PATH="$PATH:$ANDROID_SDK_HOME/tools:$ANDROID_SDK_HOME/platform-tools:$ANDROID_NDK"

WORKDIR /tmp

# Installing packages
RUN apt-get update -qq > /dev/null && \
    apt-get install -qq locales > /dev/null && \
    locale-gen "$LANG" > /dev/null && \
    apt-get install -qq --no-install-recommends \
    build-essential \
    autoconf \
    curl \
    git \
    lib32stdc++6 \
    lib32z1 \
    lib32z1-dev \
    lib32ncurses5 \
    libc6-dev \
    libgmp-dev \
    libmpc-dev \
    libmpfr-dev \
    libxslt-dev \
    libxml2-dev \
    m4 \
    ncurses-dev \
    ocaml \
    openjdk-8-jdk \
    openssh-client \
    pkg-config \
    python-software-properties \
    ruby-full \
    software-properties-common \
    unzip \
    wget \
    zip \
    zlib1g-dev > /dev/null && \
    echo "installing nodejs, npm, react-native" && \
    curl -sL -k https://deb.nodesource.com/setup_${NODE_VERSION} \
    | bash - > /dev/null && \
    apt-get install -qq nodejs > /dev/null && \
    apt-get clean > /dev/null && \
    rm -rf /var/lib/apt/lists/ && \
    npm install --quiet -g npm > /dev/null && \
    npm install --quiet -g \
    node-gyp npm-check-updates \
    react-native-cli > /dev/null && \
    npm cache clean --force > /dev/null && \
    rm -rf /tmp/* /var/tmp/*

# Install Android SDK
RUN echo "installing sdk tools" && \
    wget --quiet --output-document=sdk-tools.zip \
    "https://dl.google.com/android/repository/sdk-tools-linux-${ANDROID_SDK_TOOLS_VERSION}.zip" && \
    mkdir --parents "$ANDROID_HOME" && \
    unzip -q sdk-tools.zip -d "$ANDROID_HOME" && \
    rm --force sdk-tools.zip && \
    echo "installing ndk" && \
    wget --quiet --output-document=android-ndk.zip \
    "http://dl.google.com/android/repository/android-ndk-r${ANDROID_NDK_VERSION}-linux-x86_64.zip" && \
    mkdir --parents "$ANDROID_NDK_HOME" && \
    unzip -q android-ndk.zip -d "$ANDROID_NDK" && \
    rm --force android-ndk.zip && \
    # Install SDKs
    # Please keep these in descending order!
    # The `yes` is for accepting all non-standard tool licenses.
    mkdir --parents "$HOME/.android/" && \
    echo '### User Sources for Android SDK Manager' > \
    "$HOME/.android/repositories.cfg" && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager --licenses > /dev/null && \
    echo "installing platforms 27 and 16 " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
    "platforms;android-27" \
    "platforms;android-16" && \
    echo "installing platform tools " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
    "platform-tools" && \
    echo "installing build tools 27.0.3 " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
    "build-tools;27.0.3" && \
    echo "installing extras " && \
    yes | "$ANDROID_HOME"/tools/bin/sdkmanager \
    "extras;android;m2repository" \
    "extras;google;m2repository"

# Copy sdk license agreement files.
RUN mkdir -p $ANDROID_HOME/licenses
COPY sdk/licenses/* $ANDROID_HOME/licenses/
