module WhamHelper
  def current_user
    request.session[:user][:user][:email]
  end

  def current_user_name
    "#{request.session[:user][:user][:first_name]} #{request.session[:user][:user][:last_name]}"
  end

  def current_page(page)
    request.path_info.start_with?("/#{page}")
  end
end
