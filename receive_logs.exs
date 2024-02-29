defmodule ReceiveLogs do
  def wait_for_messages(channel) do
    receive do
      {:basic_deliver, payload, _meta} ->
        IO.puts " [x] Received #{payload}"

        wait_for_messages(channel)
    end
  end
end

{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon")
{:ok, channel} = AMQP.Channel.open(connection)

AMQP.Exchange.declare(channel, "logs", :fanout)
# AMQP.Queue.declare(channel, "task_queue", durable: true) # queue 만들기 (존재하는지 확인하기 위해 한번더. 아무리 많이 만들어도 한개만 만들어짐)
{:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)
AMQP.Queue.bind(channel, queue_name, "logs") # binding: exchange와 queue의 관계
# AMQP.Basic.qos(channel, prefetch_count: 1) # 한번에 하나 이상의 message 주지 말 것 -> 한번씩 다 주는게 아니라 안 바쁜 worker에게 배분해준다.

# RabbitMQ한테 이 process가 "task_queue" queue로부터 message를 받아야 한다는 것을 알림
AMQP.Basic.consume(channel, queue_name, nil, no_ack: true)

IO.puts " [*] Waiting for messages. To exit press CTRL+C, CTRL+C"
ReceiveLogs.wait_for_messages(channel) # data 기다리고 필요할 때 message 띄우기 무한반복
