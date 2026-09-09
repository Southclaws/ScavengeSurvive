# open.mp port

Scavenge and Survive was a SA-MP gamemode. It now runs on
[open.mp](https://open.mp), built and served without Docker. These documents
record how that was done and how to work with the result.

| Document | Read it for |
| --- | --- |
| [findings.md](findings.md) | What the project looked like before the port, what open.mp and its tooling provide, and the reasoning behind each decision. |
| [porting-log.md](porting-log.md) | Every change in order, every compile and runtime failure hit on the way, and how each was diagnosed. |
| [runbook.md](runbook.md) | How to build, run, configure and debug the server day to day. |

Start with the runbook if you just want to get the server up. Start with the
porting log if something looks strange and you want to know why it is that way.
