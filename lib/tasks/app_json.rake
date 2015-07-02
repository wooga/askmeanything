desc "Generate a .env file for what is required"
task :generate_env do
  require 'json'

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
  require 'json'

  cfg = JSON(File.read("app.json"))
  raise "Name too long, #{cfg["name"].size} > 30" if cfg["name"].size > 30
  puts "Seems ok"
end
