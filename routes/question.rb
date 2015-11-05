get '/questions/:question_id/show' do
  @question = Question.find_by_id(params[:question_id])

  if @question.nil?
    haml :"questions/not_found"
  else
    @round = @question.round
    haml :"questions/show"
  end
end
