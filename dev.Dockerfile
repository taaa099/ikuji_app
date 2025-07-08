FROM ruby:3.4.4

# 必要なパッケージをインストール
RUN apt-get update -qq && apt-get install -y nodejs yarn mysql-client

# 作業ディレクトリ作成
WORKDIR /app

# Gemfileを先にコピーし、bundle install
COPY Gemfile Gemfile.lock ./
RUN bundle install

# アプリ全体をコピー
COPY . .

# 起動時に実行するシェルスクリプト
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT [ "entrypoint.sh" ]

# ポート指定
EXPOSE 3000

# railsサーバー起動
CMD [ "rails", "server", "-b", "0.0.0.0" ]