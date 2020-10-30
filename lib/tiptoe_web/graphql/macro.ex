defmodule TipToe.GraphQL.Macro do
  defmacro paginate(name) do
    quote do
      object unquote(name) do
        field :data, non_null(list_of(non_null(unquote(name))))
        field :pagination_info, non_null(:pagination_info)
      end
    end
  end
end
