directory '/data0/hydra/current'
bind 'tcp://127.0.0.1:3000'
pidfile '/data0/hydra/shared/tmp/puma/puma.pid'
state_path '/data0/hydra/shared/tmp/puma/puma.state'
workers 4
preload_app!

environment 'production'
stdout_redirect '/data0/hydra/shared/log/puma.log', '/data0/hydra/shared/log/puma.err.log', true

daemonize true
# Allow for `touch tmp/restart.txt` to force puma to restart the app
plugin :tmp_restart

# Activate the puma control application, mapping location in the nginx config
activate_control_app 'unix:///data0/hydra/shared/sockets/pumactl.sock'
