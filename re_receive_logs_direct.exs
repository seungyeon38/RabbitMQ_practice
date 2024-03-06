# message의 일부만 subscribe
# log file에 중요한 error, console에 모든 log message 보내기

defmodule ReceiveLogsDirect do
  def wait_for_messages(channel) do
    receive do
      {:basic_deliver, payload, meta} -> # payload: message, meta: 관련 정보
        # IO.inspect(payload, label: "payload")
        # IO.inspect(meta, label: "meta")
        IO.puts " [x] Received [#{meta.routing_key}] #{payload}"

        wait_for_messages(channel)
    end
  end
end

# RabbitMQ server와 연결
{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon") # 다른 machine에 있는 broker와 연결
{:ok, channel} = AMQP.Channel.open(connection)

{severities, _, _} =
  System.argv
  |> OptionParser.parse(strict: [info:      :boolean,
                                 warning:   :boolean,
                                 error:     :boolean])

AMQP.Exchange.declare(channel, "direct_logs", :direct)

{:ok, %{queue: queue_name}} = AMQP.Queue.declare(channel, "", exclusive: true) # exclusive : consumer 연결이 끊기면, queue가 삭제됨.

for {severity, true} <- severities do
  binding_key = severity |> to_string
  AMQP.Queue.bind(channel, queue_name, "direct_logs", routing_key: binding_key)
end

AMQP.Basic.consume(channel, queue_name, nil, no_ack: true) # RabbitMQ에 특정 process가 해당 queue에서 message를 받아야 한다는 것을 알림

IO.puts " [x] Waiting for messgaes. To exit press CTRL+C, CTRL+C"

ReceiveLogsDirect.wait_for_messages(channel)
