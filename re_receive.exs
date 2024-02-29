# 이름이 있는 queue로부터 메세지 받는 프로그램

# RabbitMQ server와 연결
{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon") # 다른 machine에 있는 broker와 연결
{:ok, channel} = AMQP.Channel.open(connection)

# message가 보내질 queue 생성 (queue이름: hello)
# queue가 무조건 존재해야 함.
# 이 명령어를 아무리 많이 실행해도 한개만 만들어진다.
# send.exs 또는 receive.exs 어디에서 먼저 만들지 알 수 없으므로 두 프로그램에서 반복 선언
AMQP.Queue.declare(channel, "hello")

# 특정 Elixir process에 {:basic_deliver, payload, _meta} Elixir message가 보내짐
defmodule Receive do
  def wait_for_messages do
    receive do
      {:basic_deliver, payload, _meta} ->
        IO.puts " [x] Received #{payload}"
        wait_for_messages()
    end
  end
end

# RabbitMQ에 특정 process가 hello queue에서 message를 받아야 한다는 것을 알림
AMQP.Basic.consume(channel, "hello", nil, no_ack: true)

# RabbitMQ가 어떤 queue를 가지고 있는지, 얼마나 많은 message들이 거기에 있는지
# sudo rabbitmqctl list_queues

IO.puts " [*] Waiting for messages. To exit press CTRL+C, CTRL+C"
Receive.wait_for_messages() # data를 무한 recursion으로 기다리고 필요할 때마다 message를 보여줄 수 있게
