from server.core import Core


def main():
    host = "127.0.0.1"
    port = 6379

    core = Core(host, port)

    core_th = core.start()

    core_th.join()

    print("EXITING")


if __name__ == '__main__':
    main()
