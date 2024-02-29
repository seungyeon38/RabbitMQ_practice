# 시간이 걸리는 task를 multiple worker에게 분재하기 위한 Work Queue(Task Queue)를 만드는 프로그램
# 자원을 많이 필요로 하는 task를 즉시 하면서 완료되길 기다리는 것을 피하기 위함.

# 우리는 task를 message에 캡슐화해서 queue에 보낸다.
# 짧은 HTTP request window 동안 복잡한 task를 수행하는 것이 불가능한 웹 어플리케이션에서 유용

# RabbitMQ server와 연결
{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon") # 다른 machine에 있는 broker와 연결
{:ok, channel} = AMQP.Channel.open(connection)

# AMQP.Queue.declare(channel, "task_queue")
AMQP.Queue.declare(channel, "task_queue", durable: true)

# 명령어를 통해서 임의의 message를 보낼 수 있도록 수정
message =
  case System.argv do
    []    -> "Hello World!"
    words -> Enum.join(words, " ")
  end

AMQP.Basic.publish(channel, "", "task_queue", message, persistent: true) # message가 없어지지 않는 것을 완벽하게 보장하지는 않지만, 좀 더 보장한다.

IO.puts " [x] Send '#{message}'"
