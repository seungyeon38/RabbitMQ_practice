# Elixir process에 Elixir message를 보냄
# {:basic_deliver, payload, metadata}
defmodule Receive do
  def wait_for_messages do
    receive do
      {:basic_deliver, payload, _meta} ->
        IO.puts " [x] Received #{payload}"
        wait_for_messages()
    end
  end
end

{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon")
{:ok, channel} = AMQP.Channel.open(connection)

AMQP.Queue.declare(channel, "hello") # queue 만들기 (존재하는지 확인하기 위해 한번더. 아무리 많이 만들어도 한개만 만들어짐)

# RabbitMQ한테 이 process가 "hello" queue로부터 message를 받아야 한다는 것을 알림
AMQP.Basic.consume(channel, "hello", nil, no_ack: true)

# subscribe을 하려는 queue가 존재하는지 확실하게 해야 함.
# sudo rabbitmqctl list_queues

IO.puts " [*] Waiting for messages. To exit press CTRL+C, CTRL+C"
Receive.wait_for_messages() # data 기다리고 필요할 때 message 띄우기 무한반복
