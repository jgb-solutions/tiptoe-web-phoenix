defmodule Tiptoe.Repo.Migrations.CreateRooms do
  use Ecto.Migration

  def change do
    create table(:rooms) do
      add :user_id, :integer, null: false
      add :model_id, :integer, null: false

      timestamps(updated_at: false)
    end
  end
end
