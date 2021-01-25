defmodule TipToe.Models do
  import Ecto.Query
  alias TipToe.Repo

  alias TipToe.{Room, Photo, Model, User, Message}

  # def photos(criteria) do
  #   query = from(p in Photo)

  #   Enum.reduce(criteria, query, fn
  #     {:limit, limit}, query ->
  #       from p in query, limit: ^limit

  #     {:order, order}, query ->
  #       from p in query, order_by: [{^order, :inserted_at}]
  #   end)
  #   |> Repo.all()
  # end

  # Dataloader
  def datasource() do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  def query(Photo, %{limit: limit, scope: :user}) do
    Photo
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
  end

  def query(Room, %{scope: :user, limit: limit}) do
    Room
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
  end

  def query(Message, %{scope: :room, limit: limit}) do
    Message
    |> order_by(desc: :inserted_at)
    |> limit(^limit)
  end

  def query(queryable, _) do
    queryable
  end
end
