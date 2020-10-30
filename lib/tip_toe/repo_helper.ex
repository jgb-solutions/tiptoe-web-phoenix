defmodule TipToe.RepoHelper do
  import Ecto.Query
  alias TipToe.Repo

  def latest(query, column \\ :id) do
    from query,
      order_by: [desc: ^column]
  end

  def paginate(query, opts \\ []) do
    %Scrivener.Page{
      entries: data,
      page_number: current_page,
      page_size: per_page,
      total_entries: total,
      total_pages: total_pages
    } = Repo.paginate(query, opts)

    %{
      data: data,
      pagination_info: %{
        current_page: current_page,
        per_page: per_page,
        total: total,
        total_pages: total_pages,
        has_more_pages: current_page < total_pages
      }
    }
  end
end
