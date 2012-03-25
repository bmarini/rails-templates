gem "unicorn"
gem "foreman"
create_file "Procfile", "web: bundle exec unicorn -p $PORT"

# Mongoid
if yes?("Would you like to use Mongoid?")
  gem("mongoid")
  gem("bson_ext")

  gsub_file 'Gemfile', /gem 'sqlite3'/, "# gem 'sqlite3'"
  gsub_file 'config/application.rb', /  require 'rails\/all'/, <<-'EOS'
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

  generate("mongoid:config")
end

# Devise
if yes?("Would you like to install Devise?")
  gem("devise")
  generate("devise:install")
  model_name = ask("What would you like the user model to be called? [user]")
  model_name = "user" if model_name.blank?
  generate("devise", model_name)
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
end

# Other javascript goodies
get "https://github.com/quirkey/sammy/raw/master/lib/sammy.js", "vendor/javascripts/sammy.js"
