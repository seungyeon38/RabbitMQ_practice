# connection 만들기
{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon") # localhost에 연결 (다른 기기에 broker를 연결하려면, 이름이나 IP주소를 host: 옵션으로 명시해야 함.)
{:ok, channel} = AMQP.Channel.open(connection)

{topic, message} =
  System.argv
  |> case do
    []            -> {"anonymous.info", "Hello World!"}
    [message]     -> {"anonymous.info", message}
    [topic|words] -> {topic, Enum.join(words, " ")}
  end

{:ok, %{queue: callback_queue}} = AMQP.Exchange.declare(channel, "", exclusive: true)

AMQP.Basic.publish(channel, "", "rpc_queue", request, reply_to: callback_queue)
IO.puts " [x] Sent '[#{topic}] #message"

AMQP.Connection.close(connection)
