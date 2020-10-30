defmodule TipToe.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string, null: false, unique: true
      add :slug, :string, null: false, unique: true
    end

    create index(:categories, [:slug])
  end
end
