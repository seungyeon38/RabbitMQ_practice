# RabbitMQ server와 연결
{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon") # 다른 machine에 있는 broker와 연결
{:ok, channel} = AMQP.Channel.open(connection)

defmodule Worker do
  def wait_for_messages(channel) do
    receive do
      {:basic_deliver, payload, meta} ->
        IO.puts " [x] Received #{payload}"

        payload
        |> Kernel.to_charlist
        |> Enum.count(fn x -> x == ?. end)
        |> Kernel.*(1000) # 오래 걸리는 작업처럼
        |> :timer.sleep

        IO.puts " [x] Done."
        AMQP.Basic.ack(channel, meta.delivery_tag) # 중요

        wait_for_messages(channel)
    end
  end
end

# AMQP.Queue.declare(channel, "task_queue")
AMQP.Queue.declare(channel, "task_queue", durable: true)

# AMQP.Basic.consume(channel, "task_queue", nil, no_ack: true)
AMQP.Basic.consume(channel, "task_queue", nil)

IO.puts " [*] Waiting for messages. To exit press CTRL+C, CTRL+C"
Worker.wait_for_messages(channel)

# worker가 종료되면, processing되고 있거나 아직 handle되지 않은 메세지는 없어진다.
# 어떠한 task도 종료되지 않게 하기 위해서는, 해당 worker가 죽었을 때, 그 task가 다른 worker에게 전송되어야 한다.
# message acknowledgments (ack)
# AMQP.Basic.ack

# 위 문제를 해결해도, 여전히 RabbitMQ server가 멈췄을 때는 task가 없어진다.
# queue와 message 모두에 durable을 표시해야 한다.
# durable: true -> RabbitMQ가 restart되더라도 queue가 존재한다.
