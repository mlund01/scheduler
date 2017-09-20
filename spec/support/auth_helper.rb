module AuthHelper

	def set_valid_auth(username, password)
    request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end

  def set_invalid_auth
  	request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials("nonexistent", "userpass")
  end

  def remove_auth
  	request.env['HTTP_AUTHORIZATION'] = nil
  end

end