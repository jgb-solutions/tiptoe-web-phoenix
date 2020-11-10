defmodule TipToe.Repo.Migrations.AddPhotosTable do
  use Ecto.Migration

  def change do
    create table("photos") do
      add :caption, :string, null: false
      add :hash, :integer, unique: true, null: false
      add :uri, :string, null: false
      add :img_bucket, :string, null: false
      add :featured, :boolean, default: false
      add :detail, :text
      add :model_id, :integer, null: false
      add :category_id, :integer, null: false
      add :like_count, :integer, default: 0
      add :publish, :boolean, default: true

      timestamps()
    end

    create index(:photos, [:caption, :hash])
  end
end
