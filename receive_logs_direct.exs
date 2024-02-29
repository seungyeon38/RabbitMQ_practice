defmodule ReceiveLogsDirect do
  def wait_for_messages(channel) do
    receive do
      {:basic_deliver, payload, meta} ->
        IO.puts " [x] Received [#{meta.routing_key}] #{payload}"

        wait_for_messages(channel)
    end
  end
end

{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon")
{:ok, channel} = AMQP.Channel.open(connection)

{severities, _, _} =
  System.argv
  |> OptionParser.parse(strict: [info: :boolean,
                                 warning: :boolean,
                                 error: :boolean])

AMQP.Exchange.declare(channel, "direct_logs", :direct)

# AMQP.Queue.declare(channel, "task_queue", durable: true) # queue 만들기 (존재하는지 확인하기 위해 한번더. 아무리 많이 만들어도 한개만 만들어짐)
{:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)

for {severity, true} <- severities do
  binding_key = severity |> to_string
  AMQP.Queue.bind(channel, queue_name, "direct_logs", routing_key: binding_key)
end

# RabbitMQ한테 이 process가 "task_queue" queue로부터 message를 받아야 한다는 것을 알림
AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)

IO.puts " [*] Waiting for messages. To exit press CTRL+C, CTRL+C"
ReceiveLogsDirect.wait_for_messages(channel) # data 기다리고 필요할 때 message 띄우기 무한반복
