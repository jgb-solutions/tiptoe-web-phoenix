defmodule TipToeWeb.RoomChannel do
  use Phoenix.Channel
  # alias TipToeWeb.Presence
  alias TipToe.Chats
  alias TipToe.User

  def join("room:" <> _room, _params, socket) do
    # send(self(), :after_join)
    messages = Enum.map(Chats.list_messages(), &mapMessageToResponse(&1))

    {:ok,
     %{
       messages: Jason.encode!(messages)
     }, socket}
  end

  def handle_in(
        "new_message",
        %{
          "text" => text,
          "userId" => user_id
          # "roomId" => room_id
        },
        socket
      ) do
    message =
      Chats.create_message(%{
        text: text,
        user_id: user_id
        # room_id: room_id
      })

    broadcast_from!(socket, "new_message", mapMessageToResponse(message))

    {:noreply, socket}
  end

  defp mapMessageToResponse(message) do
    %{
      id: message.id,
      text: message.text,
      createdAt: message.inserted_at,
      user: %{
        id: message.user.id,
        name: message.user.name,
        avatar_url: User.make_avatar_url(message.user)
      }
    }
  end

  # def handle_info(:after_join, socket) do
  #   # socket.assigns.user_id
  #   {:ok, _} =
  #     Presence.track(socket, 1, %{
  #       online_at: inspect(System.system_time(:second))
  #     })

  #   push(socket, "presence_state", Presence.list(socket))
  #   {:noreply, socket}
  # end

  # TipToeWeb.Endpoint.broadcast(
  #   "room:general",
  #   "new_message",
  #   %{
  #     text: "Some message" <> Integer.to_string(Enum.random(111..9_234_234)),
  #     createdAt: "2010-12-03",
  #     user: %{
  #       id: Enum.random(1..500),
  #       name: "Some user"
  #     },
  #     id: Enum.random(500..5000)
  #   }
  # )
end
