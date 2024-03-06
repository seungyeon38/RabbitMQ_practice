defmodule ReceiveLogs do
  def wait_for_messages(channel) do
    receive do
      {:basic_deliver, payload, _meta} ->
        IO.puts " [x] Received #{payload}"

        wait_for_messages(channel)
    end
  end
end

# RabbitMQ server와 연결
{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon") # 다른 machine에 있는 broker와 연결
{:ok, channel} = AMQP.Channel.open(connection)

AMQP.Exchange.declare(channel, "logs", :fanout) # fanout : 모든 message를 모든 queue에 broadcast
# producer와 consumer 사이에 queue를 공유하면 queue에 이름을 붙이는 것이 중요하다.
# 이 logger에서는 중요하지 않음. 모든 log message들을 듣고 있어야하기 때문에.
# 현재 message에만 관심이 있다.
# Rabbit에 연결될 때마다 fresh, empty queue가 필요하다. -> queue를 랜덤 이름으로 만들면 된다. (AMQP.Queue.declare에 queue 파라미터를 안주면 된다.)
# {:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel) # queue 랜덤 이름
{:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true) # exclusive : consumer 연결이 끊기면, queue가 삭제됨.

AMQP.Queue.bind(channel, queue_name, "logs") # binding: exchange와 queue 사이의 관계
AMQP.Basic.consume(channel, queue_name, nil, no_ack: true) # RabbitMQ에 특정 process가 해당 queue에서 message를 받아야 한다는 것을 알림
IO.puts " [*] Waiting for messages. To exit press CTRL+C, CTRL+C"

ReceiveLogs.wait_for_messages(channel)
