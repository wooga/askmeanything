get '/' do
    round = Round.with_state(:active).first
    if round.nil?
      redirect '/rounds'
    else
      redirect "/rounds/#{round.id}/questions"
    end
end
