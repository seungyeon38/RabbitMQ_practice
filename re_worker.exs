# RabbitMQ server와 연결
{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon") # 다른 machine에 있는 broker와 연결
{:ok, channel} = AMQP.Channel.open(connection)

defmodule Worker do
  def wait_for_messages(channel) do
    receive do
      {:basic_deliver, payload, _meta} ->
        IO.puts " [x] Received #{payload}"

        payload
        |> Kernel.to_charlist
        |> Enum.count(fn x -> x == ?. end)
        |> Kernel.*(1000) # 오래 걸리는 작업처럼
        |> :timer.sleep

        IO.puts " [x] Done."

        wait_for_messages(channel)
    end
  end
end

AMQP.Basic.consume(channel, "task_queue", nil, no_ack: true)

IO.puts " [*] Waiting for messages. To exit press CTRL+C, CTRL+C"
Worker.wait_for_messages(channel)
