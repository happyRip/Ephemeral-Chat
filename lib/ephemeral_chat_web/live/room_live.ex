defmodule EphemeralChatWeb.RoomLive do
  use EphemeralChatWeb, :live_view
  alias EphemeralChatWeb, as: ChatWeb
  alias ChatWeb.{Endpoint, Presence}

  require EphemeralChat.Messager
  alias EphemeralChat.Messager

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    topic = "room:" <> room_id
    username = MnemonicSlugs.generate_slug(2)

    if connected?(socket) do
      Endpoint.subscribe(topic)
      Presence.track(self(), topic, username, %{})
    end

    {:ok,
     assign(socket,
       room_id: room_id,
       topic: topic,
       username: username,
       message: "",
       messages: [],
       user_list: [],
       temporary_assigns: [messages: []]
     )}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    username = socket.assigns.username
    message = Messager.new_message(message, username)
    ChatWeb.Endpoint.broadcast!(socket.assigns.topic, "new_message", message)

    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_event("form_updated", %{"chat" => %{"message" => message}}, socket) do
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new_message", payload: message}, socket) do
    messages = Messager.append(socket.assigns.messages, message)

    {:noreply, assign(socket, messages: messages)}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: joins}}, socket)
      when joins != %{} do
    [username] = Map.keys(joins)
    message = Messager.new_message("#{username} joined")

    messages =
      socket.assigns.messages
      |> Messager.append(message)

    user_list =
      socket.assigns.topic
      |> Presence.list()
      |> Map.keys()

    {:noreply, assign(socket, messages: messages, user_list: user_list)}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{leaves: leaves}}, socket)
      when leaves != %{} do
    [username] = Map.keys(leaves)
    message = Messager.new_message("#{username} left")

    messages =
      socket.assigns.messages
      |> Messager.append(message)

    user_list =
      socket.assigns.topic
      |> Presence.list()
      |> Map.keys()

    {:noreply, assign(socket, messages: messages, user_list: user_list)}
  end

  def display_message(%{uuid: uuid, content: content, author: :system}) do
    ~E"""
    <p id="<%= uuid %>" class="system-message" style="text-align:center">
      <%= content %>
    </p>
    """
  end

  def display_message(%{uuid: uuid, content: content, author: author, user: user})
      when author == user do
    ~E"""
    <p id="<%= uuid %>" class="own-message">
      <%= content %>
    </p>
    """
  end

  def display_message(%{uuid: uuid, content: content, author: username}) do
    ~E"""
    <p id="<%= uuid %>" class="user-message">
      <%= content %>
    </p>
    """
  end

  def display_author(%{author: author, uuid: uuid}) do
    ~E"""
    <p id="<%= uuid %>_usr" class="username">
      <%= author %>
    </p>
    """
  end
end

