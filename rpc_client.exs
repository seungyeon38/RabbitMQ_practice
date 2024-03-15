defmodule FibonacciRpaClient do
  def wait_for_messages(_channel, correlation_id) do
    receive do
    end
  end

  def call(n) do
    # RabbitMQ server와 연결
    {:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon") # 다른 machine에 있는 broker와 연결
    {:ok, channel} = AMQP.Channel.open(connection)

    # 메세지가 전달될 queue 만들기
    {:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true)  # exclusive : consumer 연결이 끊기면, queue가 삭제됨.

    AMQP.Basic.consume(channel, queue_name, nil, no_ack: true) # RabbitMQ에 특정 process가 해당 queue에서 message를 받아야 한다는 것을 알림
    correlation_id =
      :erlang.unique_integer
      |> :erlang.integer_to_binary
      |> Base.encode64

    request = to_string(n)
    # default exchange : routing_key로 명시된 이름을 가진 queue로(해당 queue가 존재한다면) 전달
    AMQP.Basic.publish(channel,
                      "",
                      "rpc_queue",
                      request,
                      reply_to: queue_name,
                      correlation_id: correlation_id)

    FibonacciRpaClient.wait_for_messages(channel, correlation_id)
  end
end
