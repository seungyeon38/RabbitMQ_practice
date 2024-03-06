# direct exchange를 사용하더라도, 다양한 기준으로 routing할 수 없다는 문제가 있다.
# topic exchange
# * : 한 단어 대체
# # : 0개 또는 여러 단어 대체
# #를 쓰면 fanout이랑 같고, *나 #를 안 쓰면 direct와 같이 쓸 수 있다.

# RabbitMQ server와 연결
{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon") # 다른 machine에 있는 broker와 연결
{:ok, channel} = AMQP.Channel.open(connection)

{topic, message} =
  System.argv
  |> IO.inspect(label: "emit System.argv")
  |> case do
    []            -> {"anonymous.info", "Hello World!"}
    [message]     -> {"anonymous.info", message}
    [topic|words] -> {topic, Enum.join(words, " ")}
  end

AMQP.Exchange.declare(channel, "topic_logs", :topic) # exchange 생성
AMQP.Basic.publish(channel, "topic_logs", topic, message) # send message
IO.puts " [x] Sent '[#{topic}] #{message}'"

AMQP.Connection.close(connection)
