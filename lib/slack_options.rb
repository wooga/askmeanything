require 'optparse'
require 'shellwords'

module Wham
  class SlackOptions
    attr_reader(:opts, :error_message, :text, :round, :page)

    def initialize
      @text            = nil
      @error_message   = nil
      @round           = nil
      @do_listing      = false
      @create_question = false
      @page            = 1
    end

    def parse(str)
      @opts = ::OptionParser.new do |opts|
        opts.banner = "Usage: /ama [-hlc] [-r ID] [-p NUM] TEXT"

        opts.on("-r", "--round ID", "Round id to use") do |rid|
          @round = Round.find(rid.to_i)
        end

        opts.on("-l", "--list", "List all rounds or if "+
                "round id give, list all questions in that round") do
          @do_listing = true
        end

        opts.on("-c", "--create", "Create a question in a specific "+
                "round. Requires round id.") do
          @create_question = true
        end

        opts.on("-p", "--page NUM", "When listing, show this page "+
                "number.") do |p|
          @page = p.to_i
        end

        opts.on("-h", "--help", "Show this help") do
          @error_message = "Help:"
        end
      end

      begin
        @text = @opts.parse!(Shellwords.shellwords(str)).join(" ")
      rescue Exception => e
        @error_message = e.message
      end

      self
    end

    def is_in_error?
      !@error_message.nil?
    end

    def do_listing?
      @do_listing
    end

    def create_question?
      @create_question
    end

    def have_round?
      !!@round
    end

    def help
      "*#{ @error_message}*\n#{@opts.help}"
    end
  end
end
