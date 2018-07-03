module TopHelper

  def print_top
    "User-Agent is " << request.env["HTTP_USER_AGENT"]
  end
end
