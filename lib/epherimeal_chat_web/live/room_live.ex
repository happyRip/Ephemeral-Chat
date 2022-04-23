defmodule EpherimealChatWeb.RoomLive do
  use EpherimealChatWeb, :live_view
  alias EpherimealChatWeb, as: ChatWeb
  alias ChatWeb.Endpoint
  require Logger

  @impl true
  def mount(%{"id" => room_id}, _session, socket) do
    Logger.info(socket: socket)
    topic = "room:" <> room_id
    username = MnemonicSlugs.generate_slug(2)

    if connected?(socket) do
      Endpoint.subscribe(topic)
    end

    {:ok,
     assign(socket,
       room_id: room_id,
       topic: topic,
       username: username,
       message: "",
       messages: [
         %{
           uuid: UUID.uuid4(),
           content: "#{username} joined the chat",
           username: "system"
         }
       ],
       temporary_assigns: [messages: []]
     )}
  end

  @impl true
  def handle_event("submit_message", %{"chat" => %{"message" => message}}, socket) do
    message = %{uuid: UUID.uuid4(), content: message, username: socket.assigns.username}
    Logger.info(message: message)
    ChatWeb.Endpoint.broadcast(socket.assigns.topic, "new-message", message)

    {:noreply, assign(socket, message: "")}
  end

  @impl true
  def handle_event("form_updated", %{"chat" => %{"message" => message}}, socket) do
    Logger.info(form: message)
    {:noreply, assign(socket, message: message)}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    {:noreply, assign(socket, messages: [message])}
  end
end
