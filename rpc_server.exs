defmodule FibServer do
  def fib(0), do: 0
  def fib(1), do: 1
  def fib(n) when n>1, do: fib(n-1) + fib(n-2)

  def wait_for_messages(channel) do

  end
end

# RabbitMQ server와 연결
{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon") # 다른 machine에 있는 broker와 연결
{:ok, channel} = AMQP.Channel.open(connection)

AMQP.Queue.declare(channel, "rpc_queue") # message가 보내질 queue 생성 (queue이름: rpc_queue)
