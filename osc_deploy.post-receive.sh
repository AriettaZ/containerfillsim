#!/bin/bash

# WORKS GREAT and YOU NEED TO DO THIS TO SEE THE HISTORY when in foo/
# GIT_DIR=/Users/efranz/dev/tmp/foo.git git log
# GIT_DIR=/Users/efranz/dev/tmp/foo.git GIT_WORK_TREE=. git diff

# definitely in post-update so we can handle errors etc.
# Write to STDERR to see the output!!!
# pushd and popd do so!!!

if [ $GIT_DIR = "." ]; then
  GIT_WORK_TREE="${PWD%.*}"
  NAME=`basename $GIT_WORK_TREE`
 
  if [ ! -d $GIT_WORK_TREE ]; then
    mkdir $GIT_WORK_TREE
  fi
  
  # temporary make it writable
  chmod -R ug+w $GIT_WORK_TREE
  
  GIT_WORK_TREE=$GIT_WORK_TREE git checkout -f
  GIT_WORK_TREE=$GIT_WORK_TREE git clean -f
  
  # copy files to $GIT_WORK_TREE/
  # cd into $GIT_WORK_TREE and run bundle install etc.
  
  pushd $GIT_WORK_TREE
  #
  # inside directory do fun stuff
  # bundle install --local

  # force deployment for RailsEnv for passenger apps
  echo "RailsEnv deployment" > .htaccess

  # FIXME: currently only the release engineer pushing the deployment
  # owns the deployment; we want $GROUP/$NAME
  # create deployment env file for database and dataroot 
  echo "RAILS_DATAROOT=\$HOME/awesim/$USER/$NAME" > .env.deployment
  echo "RAILS_DATABASE=\$HOME/awesim/$USER/$NAME/deployment.sqlite3" >> .env.deployment


  # overwrite database.yml
  cat << END_OF_DB_YML > config/database.yml
deployment:
  adapter: sqlite3
  database: <%= ENV["RAILS_DATABASE"] %>
  pool: 5
  timeout: 5000
END_OF_DB_YML

  # add deployment.rb to environments
  cat << END_OF_DEPLOYMENT_ENV_FILE > config/environments/deployment.rb
Rails.application.class.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # change tmp/, tmp/cache/ and log file location to be under RAILS_DATAROOT
  if ENV['RAILS_DATAROOT']
    config.paths["log"] = "#{ENV['RAILS_DATAROOT']}/log/#{ENV['USER']}.log"
    config.paths["tmp"] = "#{ENV['RAILS_DATAROOT']}/tmp/#{ENV['USER']}"
    
    config.assets.configure do |env|
      env.cache = ActiveSupport::Cache::FileStore.new("#{ENV['RAILS_DATAROOT']}/tmp/#{ENV['USER']}/cache")
    end
  end
end

END_OF_DEPLOYMENT_ENV_FILE

  popd
  
  # kill write permissions
  chmod -R a-w $GIT_WORK_TREE


  echo ""
  echo "To access this app, initialize access to this app with this command: "
  echo ""
  echo "    $GIT_WORK_TREE/osc_init rails9"
  echo ""
  echo "Where rails9 is the name of an open rails app that you can use for symlink."
  echo ""
fi

