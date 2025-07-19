FROM ruby:3.4.4

# Node.js + Yarn の最新版を公式スクリプトでインストール
RUN apt-get update -qq && apt-get install -y curl gnupg default-mysql-client \
  && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && npm install -g yarn

# 作業ディレクトリ
WORKDIR /app

# Gemfile を先にコピーして bundle install
COPY Gemfile Gemfile.lock ./
RUN bundle install

# JavaScript の依存関係をインストール ←★追加
COPY package.json yarn.lock ./
RUN yarn install

# アプリ全体をコピー
COPY . .

# 起動時のスクリプト
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT [ "entrypoint.sh" ]

# ポート指定
EXPOSE 3000

# Rails サーバ起動
CMD [ "rails", "server", "-b", "0.0.0.0" ]