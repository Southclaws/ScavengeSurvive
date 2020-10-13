FROM southclaws/sampctl as build

WORKDIR /ss

ADD gamemodes gamemodes
ADD pawn.json pawn.json

RUN sampctl p build --forceEnsure

ENTRYPOINT [ "sampctl" ]
