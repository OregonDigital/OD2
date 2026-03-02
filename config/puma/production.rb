# frozen_string_literal:true

bind 'tcp://0.0.0.0:3000'
workers 4
preload_app!
environment 'production'
# daemonize false

# Activa pumactl and enable the Yabeda puma plugin
activate_control_app
# activate yabeda puma plugin for yabeda-puma-plugin
plugin :yabeda
# activate yabeda prometheus exporter metrics endpoint
plugin :yabeda_prometheus
# URL for yabeda prometheus exporter metrics endpoint
prometheus_exporter_url "tcp://0.0.0.0:9396/metrics"
# Allow for `touch tmp/restart.txt` to force puma to restart the app
plugin :tmp_restart
