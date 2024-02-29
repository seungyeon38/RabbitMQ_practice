# 이전까지는 각 message가 정확하게 한 worker에게만 전달됨.
# 메세지가 다수의 consumer에게 간다 -> publish/subscribe pattern
# 간단한 logging system
# 2가지 프로그램으로 이루어짐: log message를 내는 프로그램 / 그걸 받아서 print하는 프로그램
# publish된 log message들은 모든 receiver에게 broadcast된다.

# producer : message를 보내느 user application
# queue : message를 저장하는 buffer
# consumer : message를 받는 user application

# 바로 queue에 message를 보낼 수 없음
# 무조건 exchange로 message를 보내야 한다.
# exchange는 한 쪽은 producer로부터 message를 받고, 다른 한 쪽은 그 message들을 queue에 push한다.
# exchange는 받은 message를 가지고 무엇을 할지 확실하게 알아야 한다. -> exchange type (direct, topic, headers, fanout)

# RabbitMQ server와 연결
{:ok, connection} = AMQP.Connection.open(host: "dev.onespring.co.kr", username: "bhseong", password: "100hoon") # 다른 machine에 있는 broker와 연결
{:ok, channel} = AMQP.Channel.open(connection)

AMQP.Exchange.declare(channel, "logs", :fanout) # fanout : 모든 message를 모든 queue에 broadcast
AMQP.Basic.publish(channel, "logs", "", message)
