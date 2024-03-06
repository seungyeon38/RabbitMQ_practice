# RabbitMQ server와 연결
{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon") # 다른 machine에 있는 broker와 연결
{:ok, channel} = AMQP.Channel.open(connection)

{severities, raw_message, _} =
  System.argv
  |> OptionParser.parse(strict: [info:     :boolean,
                                 warning:  :boolean,
                                 error:    :boolean])
  |> case do
    {[], msg, _} -> {[info: true], msg, []}
    other -> other
  end

message =
  case raw_message do
    [] -> "Hello World!"
    words -> Enum.join(words, " ")
  end

AMQP.Exchange.declare(channel, "direct_logs", :direct) # exchange 생성

for {severity, true} <- severities do
  severity = severity |> to_string
  AMQP.Basic.publish(channel, "direct_logs", severity, message) # send message (severity: 'info', 'warning', 'error')
  IO.puts " [x] Sent '[#{severity}] #{message}"
end

AMQP.Connection.close(connection)
