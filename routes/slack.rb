route :get, :post, '/slack/commands' do
  case params[:command]
  when '/ama'
    opts = Wham::SlackOptions.new.parse(params[:text])
    return opts.help if opts.is_in_error?

    case true
    when opts.create_question? && opts.have_round?
      return "Round is already closed" unless opts.round.votable?
      q=Question.create_question(:question => opts.text, :round => opts.round)
      "Created Question *#{q.question}* on round *#{opts.round.title}*"

    when opts.do_listing? && opts.have_round?
      qs = Question.join_vote_info(opts.round, "", 'all').
        page(opts.page).per_page(10)

      "Listing questions of round *#{opts.round.title}* "+
        "(Page #{opts.page} of #{qs.total_pages})\n" +
        (qs.map do |q|
           "*#{q.rank}*. _#{q.question.gsub(/\n/,' ')}_ "+
             "*#{q.score}* (#{q.up_votes} / #{q.down_votes})"
         end).join("\n")

    when opts.do_listing? && !opts.have_round?
      "Listing all rounds:\n" +
        (Round.all.map do |rnd|
           dline = rnd.votable? ? "Deadline: #{rnd.deadline}" : "Closed."
           "(Id: *#{rnd.id}*). *#{rnd.title}* #{dline}\n"+
             "_#{rnd.description.gsub(/\n/,' ')}_"
         end).join("\n")
    else
      "Sorry, I didn't understand that: '#{params[:text]}', try /ama --help"
    end
  else
    "I dunno whatcha talking about Willis? "+
      "Command Unknown: #{params[:command]}"
  end
end
