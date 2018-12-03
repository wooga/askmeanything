get '/' do
    round = Round.with_state([:active, :question_collection_phase, :voting_phase]).first
    if round.nil?
      redirect '/rounds'
    else
      redirect "/rounds/#{round.id}/questions"
    end
end
