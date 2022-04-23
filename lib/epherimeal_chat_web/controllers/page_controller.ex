defmodule EpherimealChatWeb.PageController do
  use EpherimealChatWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
