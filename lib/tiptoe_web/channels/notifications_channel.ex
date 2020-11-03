defmodule TipToeWeb.NotificationsChannel do
  use Phoenix.Channel

  def join("notifications", _params, socket) do
    {:ok, socket}
  end

  def handle_in("show_toast", params, socket) do
    # Manuall broad
    # TipToeWeb.Endpoint.broadcast("notifications", "show_toast", %{message: "showing stuff"})

    broadcast!(socket, "show_toast", params)
    {:noreply, socket}
  end
end
