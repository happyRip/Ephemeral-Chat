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

    {:ok,
     assign(socket,
       room_id: room_id,
       topic: topic,
       username: username,
       message: "",
       messages: Messager.new_container(),
       user_list: [],
       temporary_assigns: [messages: Messager.new_container()]
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
    messages = Messager.append(socket.messages, message)
    {:noreply, assign(socket, messages: messages)}
  end

  @impl true
  def handle_info(
        %{event: "presence_diff", payload: %{joins: joins, leaves: leaves}},
        socket
      ) do
    join_messages =
      joins
      |> Map.keys()
      |> Enum.map(fn username ->
        Messager.new_message("#{username} joined")
      end)

    leave_messages =
      leaves
      |> Map.keys()
      |> Enum.map(fn username ->
        Messager.new_message("#{username} left")
      end)

    user_list =
      Presence.list(socket.assigns.topic)
      |> Map.keys()

    {:noreply,
     assign(socket,
       messages: join_messages ++ leave_messages,
       user_list: user_list
     )}
  end

  def display_message(%{uuid: uuid, content: content, author: :system}) do
    ~E"""
    <div id="<%= uuid %>_div" class="chat-message">
      <p id="<%= uuid %>" class="system-message" style="text-align:center">
        <%= content %>
      </p>
    </div>
    """
  end

  def display_message(%{uuid: uuid, content: content, author: author, user: user})
      when author == user do
    ~E"""
    <div id="<%= uuid %>_div" class="chat-message">
      <p id="<%= uuid %>" class="own-message">
        <%= content %>
      </p>
    </div>
    """
  end

  def display_message(%{uuid: uuid, content: content, author: username}) do
    ~E"""
    <div id="<%= uuid %>_div" class="chat-message">
      <p id="<%= uuid %>_usr" class="username">
        <%= username %>
      </p>
      <p id="<%= uuid %>" class="user-message">
        <%= content %>
      </p>
    </div>
    """
  end

end

defmodule Messager do

  def new_message(content, author \\ :system)

  def new_message(content, :system) do
    %{uuid: UUID.uuid4(), content: content, author: :system}
  end

  def new_message(content, author) do
    %{uuid: UUID.uuid4(), content: content, author: author}
  end

  def append([{author, messages} | tail], message) when author == message.author do
    message = Map.delete(message, :author)

    [{author, [message | messages]} | tail]
  end

  def append({author, messages}, message) when author == message.author do
    message = Map.delete(message, :author)

    [{author, [message | messages]}]
  end

  def append(messages, message) do
    [new_container(message) | messages]
  end

  def new_container(), do: {}

  def new_container(message) do
    author = message.author
    message = Map.delete(message, :author)

    {author, [message]}
  end
end
