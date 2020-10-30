defmodule TipToeWeb.Resolvers.Utils do
  alias TipToe.Repo
  import Ecto.Query
  alias TipToe.User
  alias TipToe.Category
  alias TipToe.Photo
  alias TipToe.Model
  import TipToe.Helper

  def upload_url(
        %{
          input: %{
            name: name,
            bucket: bucket
          }
        } = args,
        %{
          context: %{
            current_user: _current_user
          }
        }
      ) do
    public = args[:public] || false
    attachment = args[:attachment] || false

    file_path = make_upload_file_path(name)

    query_params =
      []
      |> append_if(public, {"x-amz-acl", "public-read"})
      |> append_if(attachment, {"Content-Disposition", "attachment; filename=" <> name})

    {:ok, url} =
      ExAws.Config.new(:s3)
      |> ExAws.S3.presigned_url(
        :put,
        bucket,
        file_path,
        expires_in: 10 * 60 * 60,
        query_params: query_params
      )

    {:ok,
     %{
       signed_url: url,
       filename: file_path
     }}
  end

  defp make_upload_folder() do
    user = %{id: 1}

    %{
      year: year,
      month: month,
      day: day
    } = Date.utc_today()

    "user_" <> to_string(user.id) <> "/#{year}/#{month}/#{day}"
  end

  defp make_upload_file_name(name) do
    to_string(:os.system_time(:millisecond)) <> Path.extname(name)
  end

  defp make_upload_file_path(name) do
    make_upload_folder() <> "/" <> make_upload_file_name(name)
  end

  def facebook_login_url(args, _resolution) do
    # todo
    {:ok, "Yeah"}
  end

  def download(args, _resolution) do
    # todo
    {:ok, "Yeah"}
  end

  def search(args, _resolution) do
    result =
      Enum.map([Photo, Model], fn struct ->
        do_search(struct, args.term)
      end)

    {:ok, result}
  end

  def do_search(%Photo{} = struct, term) do
    query =
      from t in struct,
        where: like(t.title, ^term),
        select: [:id, :title]

    Repo.all(query)
  end

  def do_search(%Model{} = struct, term) do
    query =
      from t in struct,
        where: like(t.title, ^term),
        select: [:id, :title]

    Repo.all(query)
  end
end
