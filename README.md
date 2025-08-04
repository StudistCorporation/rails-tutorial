# Rails tutorial

このリポジトリは、スタディストで利用されている Ruby/Rails について学ぶためのリポジトリです。※

※ [Ruby on Rails チュートリアル](https://railstutorial.jp/)とは関係ありません

## Requirements

- macOS / Linux / WSL
- [mise](https://mise.run/) - 高速なバージョン管理ツール

### 事前準備

#### macOS
```bash
# Homebrewがない場合はインストール
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 開発ツール
xcode-select --install

# 必要なライブラリ
brew install sqlite3 zeromq
```

#### Linux (Ubuntu/Debian)
```bash
# ビルドに必要なパッケージ
sudo apt-get update
sudo apt-get install -y \
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
  libsqlite3-dev \
  libzmq3-dev
```

#### WSL
上記Linuxの手順と同じ

## Setup

1. このレポをクローン
   ```bash
   git clone github.com:StudistCorporation/rails-tutorial
   cd rails-tutorial
   ```

2. mise をインストール
   ```bash
   # macOS/Linux/WSL共通
   curl https://mise.run | sh
   
   # zshの場合
   echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
   source ~/.zshrc
   
   # bashの場合
   echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
   source ~/.bashrc
   ```

3. 言語をインストール
   ```bash
   mise install  # .tool-versionsを自動で読み込みます
   ```

4. 依存パッケージをインストール
   ```bash
   # Ruby gems
   cd manual && bundle install && cd ..
   
   # Python packages (Jupyter用)
   pip install -r notebooks/requirements.txt
   
   # iruby (Ruby用Jupyterカーネル)
   gem install irb iruby
   iruby register --force
   ```

## アプリケーションの起動方法

### Jupyter Notebook の起動
```bash
cd notebooks
jupyter notebook
# ブラウザが自動で開きます（http://localhost:8888）
```

### マニュアル管理アプリの起動
```bash
cd manual

# データベースセットアップ（初回のみ）
bundle exec rails db:create
bundle exec rails db:migrate

# サーバー起動（別々のターミナルで実行）
# Rails API
bundle exec rails server

# Vue.js フロントエンド（別ターミナル）
npm install  # 初回のみ
npm run dev

# または同時起動
bundle exec foreman start -f Procfile.dev
```

## Ruby 基礎

Ruby の基礎は、Jupyter Notebook を利用して学びます。  
`notebooks/ruby_basics.ipynb` を開くと、Ruby の基礎を学ぶことができます。

最低限の情報のみ記載しているので、もっと知りたい場合は以下の書籍や Ruby のコミュニティに参加してください。

- [プロを目指す人のための Ruby 入門](https://gihyo.jp/book/2021/978-4-297-12437-3)
- [研鑽 Ruby プログラミング](https://www.lambdanote.com/products/polished-ruby)

## Rails の教科書

[Rails の教科書](https://railstutorial.jp/textbook)を使って、Rails の基礎を学びます。

## マニュアル管理アプリ

マニュアル管理アプリは、Rails+Vueを使って簡易的なマニュアル閲覧アプリを作成します。
Jupyter Notebook を見ながら、実際にコマンドを実行してアプリを構築していきます。 
`notebooks/manual.ipynb` を開くと、手順が見えるので`Terminal`上でコマンドを実行しながら進めていってください。

