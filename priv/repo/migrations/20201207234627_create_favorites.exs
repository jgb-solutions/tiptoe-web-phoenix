defmodule Tiptoe.Repo.Migrations.CreateFavorites do
  use Ecto.Migration

  def change do
    create table(:favorites) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :photo_id, references(:photos, on_delete: :delete_all)

      timestamps(updated_at: false)
    end

    create index(:favorites, [:user_id])
    create index(:favorites, [:photo_id])
    create unique_index(:favorites, [:user_id, :photo_id])
  end
end
