defmodule MedivhWeb.PageController do
  use MedivhWeb, :controller

  def index(conn, _params) do
    users =
      case Medivh.Users.get_users() do
        {:ok, users} -> users
        {:error, _} -> []
      end

    conn
    |> assign(:users, users)
    |> render("index.html")
  end
end
