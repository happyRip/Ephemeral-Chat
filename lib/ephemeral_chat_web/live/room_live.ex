defmodule EphemeralChatWeb.RoomLive do
  use EphemeralChatWeb, :live_view
  alias EphemeralChatWeb, as: ChatWeb
  alias ChatWeb.{Endpoint, Presence}

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    username = MnemonicSlugs.generate_slug(2)

    if connected?(socket) do
      Endpoint.subscribe(topic)
      Presence.track(self(), topic, username, %{})
    end

    {
      :ok,
      assign(socket,
        room_id: room_id,
        topic: topic,
        username: username,
        message: "",
        messages: [],
        user_list: [],
        temporary_assigns: [
          messages: []
        ]
      )
    }
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    username = socket.assigns.username
    message = create_message(message, username)
    ChatWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)

    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_event("form_updated", %{"chat" => %{"message" => message}}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    {:noreply, assign(socket, messages: [message])}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves:
  leaves}}, socket) do
    join_messages =
      joins
      |> Map.keys()
      |> Enum.map(fn username ->
        create_message("#{username} joined")
      end)

    leave_messages =
      leaves
      |> Map.keys()
      |> Enum.map(fn username ->
        create_message("#{username} left")
      end)

    user_list = Presence.list(socket.assigns.topic)
      |> Map.keys()

    {:noreply, assign(socket, messages: join_messages ++ leave_messages,
    user_list: user_list)}
  end

  def display_message(%{type: :system, uuid: uuid, content: content}) do
    ~E"""
    <p id="<%= uuid %>"><em><%= content %></em></p>
    """
  end

  def display_message(%{uuid: uuid, content: content, username: username}) do
    ~E"""
    <p id="<%= uuid %>"><strong><%= username %></strong>: <%= content %></p>
    """
  end

  defp create_message(content, username \\ :system)

  defp create_message(content, :system) do
    %{type: :system, uuid: UUID.uuid4(), content: content}
  end

  defp create_message(content, username) do
    %{uuid: UUID.uuid4(), content: content, username: username}
  end
end
