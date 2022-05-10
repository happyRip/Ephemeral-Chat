defmodule EphemeralChatWeb.PageLive do
  use EphemeralChatWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: %{})}
  end

  @impl true
  def handle_event("random-room", _params, socket) do
    random_slug = MnemonicSlugs.generate_slug(4)
    room_url = "/" <> random_slug
    {:noreply, push_redirect(socket, to: room_url)}
  end
end
