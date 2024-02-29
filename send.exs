# connection 만들기
{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon") # localhost에 연결 (다른 기기에 broker를 연결하려면, 이름이나 IP주소를 host: 옵션으로 명시해야 함.)
{:ok, channel} = AMQP.Channel.open(connection)

AMQP.Queue.declare(channel, "hello") # 메세지가 전달될 queue 만들기 ("hello" queue)

# exchange
AMQP.Basic.publish(channel, "", "hello", "Hello World!")
IO.puts " [x] Sent 'Hello World!'"

# program을 끝내기 전에 network buffer가 flush 됐는지, message가 RabbitMQ에 제대로 전달이 됐는지 확인해야 함.
AMQP.Connection.close(connection)
