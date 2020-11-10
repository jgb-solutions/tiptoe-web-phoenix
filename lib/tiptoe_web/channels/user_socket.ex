defmodule TipToeWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "notifications", TipToeWeb.NotificationsChannel
  channel "room:*", TipToeWeb.RoomChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case Phoenix.Token.verify(
           socket,
           Application.fetch_env!(:tiptoe, :auth_salt),
           token,
           max_age: Application.fetch_env!(:tiptoe, :auth_max_age)
         ) do
      {:ok, user_id} ->
        {:ok, assign(socket, :current_user, user_id)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.current_user}"
end
