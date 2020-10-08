apt_update 'all platforms' do
  frequency 86400
  action :periodic
end


# --- Install packages we need ---
package 'docker.io'

service 'docker' do
  supports status: true, restart: true, reload: true
  action [ :enable, :start ]
end
