require 'active_support'
require 'active_support/core_ext/object/blank'
require 'json'

desc "Start a pry shell and load all gems"
task :shell do
  require_relative 'app.rb'
  require 'pry'
  Pry.editor = "emacs"
  Pry.start
end

desc "Generate a .env file for what is required"
task :generate_env do
  if File.exists?(".env")
    `mv .env .env.#{DateTime.now.strftime("%H%m%S%d%m%Y")}`
  end
  cfg = JSON(File.read("app.json"))

  File.open('.env', "w+") do |file|
    file << "## Environment for #{cfg["name"]}"
    cfg["env"].each do |name, hsh|
      req = (hsh["required"]==false) ? "No" : "Yes"
      hsh['value'] = if hsh['generator'] == "secret"
                       SecureRandom.uuid.gsub(/-/,'')
                     else
                       hsh["value"]
                     end

      file << ["## #{hsh["description"]} (Required? #{req})",
               "#{name}=#{hsh['value']}", "", ""].join("\n")
    end
  end
end

desc "Verify the app.json"
task :verify_app_json do
  cfg = JSON(File.read("app.json"))
  raise "Name too long, #{cfg["name"].size} > 30" if cfg["name"].size > 30
  puts "Seems ok"
end
