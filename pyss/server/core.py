from threading import Thread

from redis import StrictRedis


class CoreWorker(Thread):
    def __init__(self, host, port):
        super().__init__()
        self.interface = StrictRedis(host, port)

    def run(self):
        print("Starting CoreWorker")
        while True:
            reply = self.interface.blpop("samp.core")
            if len(reply) < 2:
                print("ERROR: reply length is", len(reply))

            message = reply[1].decode('utf-8')

            print("> '%s'" % message)

            if message == "exit":
                break


class Core():
    def __init__(self, host, port):
        self.host = host
        self.port = port

    def start(self):
        core = CoreWorker(self.host, self.port)
        core.daemon = True
        core.start()
        return core
