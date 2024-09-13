FROM mcr.microsoft.com/devcontainers/base:bookworm

# Install packages
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    git \
    libssl-dev \
    zlib1g-dev \
    libyaml-dev \
    libreadline-dev \
    libncurses5-dev \
    libffi-dev \
    libgdbm-dev \
    libzmq3-dev \
    libsqlite3-dev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

USER vscode
WORKDIR /workspace
SHELL ["/bin/zsh", "-c"]

# asdfのインストール
ENV ASDF_VERSION=v0.14.1
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch $ASDF_VERSION \
    && echo '. "$HOME/.asdf/asdf.sh"' >> ~/.zshrc

# Install & Configure asdf plugins
RUN . $HOME/.asdf/asdf.sh \
    && asdf plugin add ruby \
    && asdf plugin add nodejs \
    && asdf plugin add python

# Install tools
COPY .tool-versions /workspace/.tool-versions
RUN . $HOME/.asdf/asdf.sh \
    && asdf install
RUN . $HOME/.asdf/asdf.sh \
    && cat .tool-versions | grep -v '#' | xargs -n 2 asdf install

# Install packages for Python
COPY notebooks/requirements.txt /workspace/requirements.txt
RUN . $HOME/.asdf/asdf.sh \
    && pip install --upgrade pip \
    && pip install -r requirements.txt

# Install packages for Ruby
RUN . $HOME/.asdf/asdf.sh \
    && gem install irb iruby \
    && iruby register --force

# Install packages for Node.js
RUN . $HOME/.asdf/asdf.sh \
    && npm install -g yarn

ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
