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
    when 'deactivate' then Round.find(params[:id]).deactivate
    when 'finalize' then Round.find(params[:id]).finalize
  end
  redirect '/rounds'
end
