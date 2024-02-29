# queue에 single message 보내는 프로그램
# 이름이 있는 queue에 메세지 보내는 프로그램

# RabbitMQ server와 연결
{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon") # 다른 machine에 있는 broker와 연결
{:ok, channel} = AMQP.Channel.open(connection)

# message가 보내질 queue 생성 (queue이름: hello)
AMQP.Queue.declare(channel, "hello")

# RabbitMQ에서 message는 queue에 직접 보내질 수 없다. exchange를 통해서만 보내질 수 있다.
# 여기서는 X

AMQP.Basic.publish(channel, "", "hello", "Hello  World!")
IO.puts " [x] Sent 'Hello World!'"

# network buffer flush, RabbitMQ에 message가 실제로 잘 보내졌는지 -> close connection을 통해 할 수 있다.
AMQP.Connection.close(connection)
