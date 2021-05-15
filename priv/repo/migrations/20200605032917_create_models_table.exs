defmodule TipToe.Repo.Migrations.CreateModels do
  use Ecto.Migration

  def change do
    create table(:models) do
      add :stage_name, :string, null: false
      add :hash, :integer, unique: true, null: false
      add :poster, :string
      add :img_bucket, :string, null: false
      add :user_id, references(:users, on_delete: :delete_all)
      add :bio, :text
      add :facebook, :string
      add :twitter, :string
      add :instagram, :string
      add :youtube, :string
      add :verified, :boolean, default: false

      timestamps()
    end

    create index(:models, [:name, :stage_name, :hash])
  end
end
