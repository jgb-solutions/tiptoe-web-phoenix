defmodule TipToeWeb.RoomChannel do
  use Phoenix.Channel
  alias TipToeWeb.Presence

  def join("room:" <> _room, _params, socket) do
    send(self(), :after_join)

    {:ok, socket}
  end

  def handle_in(
        "new_message",
        %{
          "text" => text,
          "userId" => user_id,
          "createdAt" => createdAt
        } = params,
        socket
      ) do
    new_params = %{
      id: Enum.random(1..20000),
      text: text,
      user: %{
        id: user_id,
        name: "Some name"
      },
      createdAt: createdAt
    }

    broadcast_from!(socket, "new_message", new_params)

    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    # socket.assigns.user_id
    {:ok, _} =
      Presence.track(socket, 1, %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

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
