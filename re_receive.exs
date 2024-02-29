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
      {:baisc_deliver, payload, _meta} ->
        IO.puts " [x] Received #{payload}"
        wait_for_messages()
    end
  end
end
