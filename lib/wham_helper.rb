module WhamHelper
  def current_user
    request.session['email']
  end

  def current_user_name
    request.session['username'].to_s.split(' ').map{|name| name.capitalize}.join(' ')
  end

  def current_page(page)
    request.path_info.start_with?("/#{page}")
  end
end
