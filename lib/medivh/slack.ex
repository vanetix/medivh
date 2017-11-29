defmodule Medivh.Slack do
  use Slack

  alias Task.Supervisor
  alias Medivh.{Users, TaskSupervisor}

  defp token(), do: Application.fetch_env!(:medivh, :slack_token)

  def child_spec(_) do
    %{
      id: __MODULE__,
      start: {Slack.Bot, :start_link, [__MODULE__, [], token(), %{name: __MODULE__}]},
      restart: :permanent,
      shutdown: 5000,
      type: :worker
    }
  end

  def handle_event(%{type: "user_change", user: user}, slack, state) do
    notify_change(user)

    {:ok, state}
  end

  def handle_event(%{type: "presence_change", user: id}, slack, state) do
    slack.users
    |> Map.get(id)
    |> notify_change()

    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:get, :users, pid}, slack, state) do
    send pid, {:users, slack.users}

    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}

  defp notify_change(%{is_bot: false, deleted: false} = user) do
    Supervisor.start_child(TaskSupervisor, Users, :user_update, [user])
  end
  defp notify_change(_), do: nil
end
