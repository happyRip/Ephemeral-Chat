defmodule EphemeralChat.Messager do
  def new_message(content, author \\ :system)

  def new_message(content, :system) do
    %{uuid: UUID.uuid4(), content: content, author: :system}
  end

  def new_message(content, author) do
    %{uuid: UUID.uuid4(), content: content, author: author}
  end

  def append(messages, []), do: messages

  def append([%{author: author, uuid: uuid, messages: messages} | tail], message)
      when author == message.author do
    message = Map.delete(message, :author)

    [%{author: author, uuid: uuid, messages: [message | messages]} | tail]
  end

  def append(%{author: author, uuid: uuid, messages: messages}, message)
      when author == message.author do
    message = Map.delete(message, :author)

    [%{author: author, uuid: uuid, messages: [message | messages]}]
  end

  def append(messages, message) do
    [new_container(message) | messages]
  end

  def new_container(), do: %{}

  def new_container(message) do
    uuid = UUID.uuid4()
    {author, message} = Map.pop(message, :author)

    %{author: author, uuid: uuid, messages: [message]}
  end
end

