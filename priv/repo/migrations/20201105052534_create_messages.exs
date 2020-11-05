defmodule Tiptoe.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :text, :string, null: false
      add :user_id, :integer, null: false
      # add :room_id, :integer, null: false

      timestamps(updated_at: false)
    end

  end
end
