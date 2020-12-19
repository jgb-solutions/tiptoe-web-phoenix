defmodule Tiptoe.Repo.Migrations.CreateFollowers do
  use Ecto.Migration

  def change do
    create table(:followers) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :model_id, references(:models, on_delete: :delete_all)

      timestamps(updated_at: false)
    end

    create index(:followers, [:user_id])
    create index(:followers, [:model_id])
    create unique_index(:followers, [:user_id, :model_id])
  end
end
