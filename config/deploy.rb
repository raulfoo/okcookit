def set_application_paths(app)
  set :deploy_to, "/opt/#{app}"
  set :staging_path, "/tmp/#{app}"
  set :local_path, Dir.pwd
  set :release_path, "#{deploy_to}/releases/#{Time.now.strftime("%Y%m%d%H%M")}"
end

def set_common_environment
  env :db_host, "localhost"
  env :db_name, "okc"
  env :db_user, "okcookit"
end

set :app, "okcookit"
set_application_paths(app)
set :user, "okcookit"

role :root_user, :user => "root"
role :okcookit_user, :user => "okcookit"

destination :vagrant do
  set :domain, "okcookit-vagrant"
  set_common_environment
  env :rack_env, "production"
  env :port, 7200
end

destination :staging do
  set :app, "okcookit_staging"
  set_application_paths(app)
  set :domain, "173.255.223.11"
  set_common_environment
  env :rack_env, "staging"
  env :db_name, "okc_staging"
  env :db_user, "okcookit_staging"
  env :port, 7100
  env :unicorn_workers, 2
  env :s3_bucket, "staging.okcookit.com"
end

destination :prod do
  set :domain, "173.255.223.11"
  set_common_environment
  env :rack_env, "production"
  env :db_name, "okc"
  env :db_user, "okcookit"
  env :port, 7200
  env :unicorn_workers, 10
  env :s3_bucket, "okcookit.com"
end

#after "deploy:symlink", "deploy:update_crontab"

#namespace :deploy do
#  desc "Update the crontab file"
#  task :update_crontab, :roles => :db do
#    run "cd #{release_path} && whenever --update-crontab #{app}"
#  end
#end

# Load secure credentials
if ENV.has_key?("OKCOOKIT_CREDENTIALS") && File.exist?(ENV["OKCOOKIT_CREDENTIALS"])
  load ENV["OKCOOKIT_CREDENTIALS"]
else
  puts "Unable to locate the file $OKCOOKIT_CREDENTIALS. You need this to deploy."
  exit 1
end
