defmodule TipToeWeb.UserSocket do
  use Phoenix.Socket

  use Absinthe.Phoenix.Socket,
    schema: TipToeWeb.GraphQL.Schema

  ## Channels
  channel "notifications", TipToeWeb.NotificationsChannel
  channel "room:*", TipToeWeb.RoomChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case Phoenix.Token.verify(
           socket,
           Application.fetch_env!(:tiptoe, :auth_salt),
           token
         ) do
      {:ok, user_id} ->
        socket =
          Absinthe.Phoenix.Socket.put_options(socket,
            context: %{
              current_user: user_id
            }
          )

        {:ok, assign(socket, :current_user, user_id)}

      {:error, _reason} ->
        :error
    end
  end

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.current_user}"
end
