defmodule Medivh.Users do
  @doc """
  Get the users from the slack `GenServer`
  """
  def get_users(opts \\ []) do
    timeout = Keyword.get(opts, :timeout, 5000)

    send Medivh.Slack, {:get, :users, self()}

    receive do
      {:users, users} ->
        {:ok, map_users(users)}
    after
      timeout ->
        {:error, :timeout}
    end
  end

  @doc """
  """
  def user_update(user) do
    user =
      %{user.id => map_user(user)}

    MedivhWeb.Endpoint.broadcast!("users:lobby", "user:update", user)
  end

  defp map_users(users) do
    users
    |> Enum.reject(fn({_, v}) ->
      v[:deleted] || v[:is_bot] || v[:id] == "USLACKBOT"
    end)
    |> Enum.into(%{}, fn({k, v}) ->
      {k, map_user(v)}
    end)
  end

  defp map_user(%{presence: status, profile: profile}) do
    %{
      name: Map.get(profile, :real_name_normalized),
      avatar: Map.get(profile, :image_72),
      status: status,
      status_text: nil,
      status_emoji: nil
    }
  end
end
