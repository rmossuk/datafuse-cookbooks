include_recipe "deploy"

node[:deploy].each do |application, deploy|

  Chef::Log.info("Running deploy/before_migrate.rb...")

  Chef::Log.info("Symlinking #{deploy[:current_path]}/public/assets to #{deploy[:deploy_to]}/shared/assets")

  directory "#{deploy[:deploy_to]}/shared/assets" do
    group deploy[:group]
    owner deploy[:user]
    action :create
  end

  link "#{deploy[:current_path]}/public/assets" do
    to "#{deploy[:deploy_to]}/shared/assets"
  end

  rails_env = deploy[:rails_env]
  Chef::Log.info("Precompiling assets for RAILS_ENV=#{rails_env}...")

  execute "rake assets:precompile" do
    cwd deploy[:current_path]
    command "bundle exec rake assets:precompile;
            chown -R #{deploy[:user]}.#{deploy[:group]} #{deploy[:deploy_to]}/shared/assets;
            chown -R #{deploy[:user]}.#{deploy[:group]} #{deploy[:current_path]}/tmp"
    environment "RAILS_ENV" => rails_env
    action :run
  end


end
