desc "Start a pry shell and load all gems"
task :shell  => :environment do
  require 'pry'
  Pry.editor = "emacs"
  Pry.start
end
