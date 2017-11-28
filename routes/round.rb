get '/rounds' do
  @rounds = Round.page(params[:page])
  haml :'rounds/rounds'
end

get '/rounds/create' do
  @round = Round.new
  haml :'rounds/create'
end

post '/rounds/create' do
  @round = Round.new(params[:round])
  if @round.save
    redirect '/rounds'
  else
    haml :'rounds/create'
  end
end

get '/rounds/:id/edit' do
  @round = Round.find(params[:id])
  haml :'rounds/edit'
end

post '/rounds/:id/update' do
  @round = Round.find(params[:id])
  if @round.update(params[:round])
    redirect '/rounds'
  else
    haml :'rounds/edit'
  end
end

post '/rounds/:id/state_update' do
  case params[:state]
    when 'activate' then Round.find(params[:id]).activate
    when 'question_phase' then Round.find(params[:id]).start_collect_questions
    when 'voting_phase' then Round.find(params[:id]).start_voting
    when 'deactivate' then Round.find(params[:id]).deactivate
    when 'finalize' then Round.find(params[:id]).finalize
  end
  redirect '/rounds'
end

##
## Questions for a round.
##
get '/rounds/:id/questions' do
  params[:per_page] = params[:per_page].try(:to_i) || session[:per_page] || 50
  session[:per_page] = params[:per_page]

  @round = Round.find(params[:id])
  @questions = Question.join_vote_info(@round, current_user, params[:filter]).page(params[:page]).per_page(params[:per_page])

  haml :index
end

get '/rounds/:id/questions/create' do
  @round = Round.find(params[:id])
  @question = Question.new(:round => @round)
  haml :'questions/create'
end

post '/rounds/:id/questions/create' do
  params[:question] ||= {}
  params[:question][:round_id] = params[:id]

  @round = Round.find(params[:id])
  halt 400, 'Round is already closed' unless @round.question_collection_phase?

  if Question.create_question_with_vote(params[:question], session[:email])
    redirect "/rounds/#{@round.id}/questions"
  else
    haml :"questions/create"
  end
end

post "/rounds/:id/questions/:question_id/vote" do
  @round = Round.find(params[:id])
  halt 400, 'Voting is not possible anymore' unless @round.votable?

  question = Question.find(params[:question_id])

  if question.vote(params[:value].to_i, current_user)
    json({
      :id => question.id,
      :html =>  haml(:'questions/_list_item',
        :layout => false,
        :locals => {
          :question => question,
          :rank => params[:rank]
        }
      )
    })
  else
    halt 500, 'Could not save vote.'
  end
end
