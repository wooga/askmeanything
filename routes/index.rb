get '/' do
    round = Round.with_state(:active).first
    if round.nil?
      redirect '/rounds/29/questions'
    else
      redirect "/rounds/#{round.id}/questions"
    end
end
