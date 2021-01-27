#!/bin/sh

# starting nginx in background
mkdir -p /run/nginx
nginx

# running the app
cd /cs-managers
bundle exec ruby boot.rb

