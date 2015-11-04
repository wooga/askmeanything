get '/rounds/:id/questions' do
  params[:per_page] = params[:per_page].try(:to_i) || session[:per_page] || 50
  session[:per_page] = params[:per_page]

  @round = Round.find(params[:id])
  @questions = Question.join_vote_info(@round, current_user, params[:filter])
    .page(params[:page]).per_page(params[:per_page])

  haml :index
end

get '/rounds/:id/questions/:question_id' do
  @round = Round.find(params[:id])
  @question = Question.find(params[:question_id])
  haml :single_question
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
  halt 400, 'Round is already closed' unless @round.votable?

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
          :question => question
        }
      )
    })
  else
    halt 500, 'Could not save vote.'
  end
end
