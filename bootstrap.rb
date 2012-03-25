# Variables
remote_base_url = "https://raw.github.com/bmarini/rails-templates/master"

# Unicorn and foreman
gem "unicorn"
gem "foreman"
create_file "Procfile", "web: bundle exec unicorn -p $PORT"

# Initial homepage
remove_file "public/index.html"
get "#{remote_base_url}/files/app/controllers/home_controller.rb", "app/controllers/home_controller.rb"
get "#{remote_base_url}/files/app/views/home/index.html.erb", "app/views/home/index.html.erb"
route "root :to => 'home#index'"

# Mongoid
if yes?("Would you like to use Mongoid?")
  gem "mongoid"
  gem "bson_ext"

  gsub_file 'Gemfile', /gem 'sqlite3'/, "# gem 'sqlite3'"
  gsub_file 'config/application.rb', /require 'rails\/all'/, <<-'EOS'
  require 'rails'

  %w(
    action_controller
    action_mailer
    rails/test_unit
    sprockets
  ).each do |framework|
    require "#{framework}/railtie"
  end
  EOS

  gsub_file 'config/environments/development.rb', /config.active_record/, '# config.active_record'
  gsub_file 'config/environments/test.rb', /config.active_record/, '# config.active_record'

  generate "mongoid:config"
end

# Devise
if yes?("Would you like to install Devise?")
  gem "devise"
  generate "devise:install"

  model_name = ask("What would you like the user model to be called? [user]")
  model_name = "user" if model_name.blank?

  generate "devise", model_name
end

# Twitter's Bootstrap
if yes?("Would you like to install twitter bootstrap?")
  inside "tmp" do
    run "curl -sO http://twitter.github.com/bootstrap/assets/bootstrap.zip", :capture => true
    run "unzip bootstrap.zip", :capture => true
  end

  run "cp tmp/bootstrap/css/bootstrap.css vendor/assets/stylesheets/"
  run "cp tmp/bootstrap/css/bootstrap-responsive.css vendor/assets/stylesheets/"

  run "cp tmp/bootstrap/js/bootstrap.js vendor/assets/javascripts/"

  empty_directory "public/img"
  run "cp tmp/bootstrap/img/* public/img/"

  insert_into_file(
    "app/assets/stylesheets/application.css",
    " *= require bootstrap\n *= require bootstrap-responsive\n",
    :after => " *= require_self\n"
  )

  insert_into_file(
    "app/assets/javascripts/application.js",
    "//= require bootstrap\n",
    :after => "//= require jquery_ujs\n"
  )

  append_to_file "app/assets/stylesheets/application.css", "body { padding-top: 60px; }\n"

  get "#{remote_base_url}/files/app/helpers/alerts_helper.rb", "app/helpers/alerts_helper.rb"
  get "#{remote_base_url}/files/app/views/layouts/bootstrap.html.erb", "app/views/layouts/application.html.erb"
end

# Other javascript goodies
get "https://github.com/quirkey/sammy/raw/master/lib/sammy.js", "vendor/assets/javascripts/sammy.js"
