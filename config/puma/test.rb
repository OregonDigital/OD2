directory '/data'
bind 'tcp://0.0.0.0:3001'
pidfile '/data/tmp/pids/puma.pid'
preload_app!
environment 'test'
daemonize true
