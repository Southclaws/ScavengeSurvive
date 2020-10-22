# -
# Builder - Builds the runner application
# -

FROM golang as build

WORKDIR /ss

ADD go.mod .
ADD go.sum .
ADD main.go .
ADD runner/ runner/
RUN ls -la
RUN go build -o scavenge-survive

# -
# Runtime - Uses the runner to launch the server
# -

FROM southclaws/sampctl as run

RUN apt update && apt install -y uuid-dev:i386 curl

WORKDIR /server

COPY --from=build /ss/scavenge-survive /ss/scavenge-survive
ENV PATH="/ss:${PATH}"
ENV AUTO_BUILD=1

ENTRYPOINT [ "scavenge-survive" ]
