# Multi-stage build: compile in builder, ship from minimal alpine
FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY go.mod ./
COPY . .
# go mod tidy populates go.sum from the imports actually referenced in source.
# Without this, `go build` fails on "missing go.sum entry" because we don't
# commit go.sum to the repo (see README — keeps the skeleton minimal).
RUN go mod tidy
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/app .

FROM alpine:3.20
RUN adduser -D -u 10001 app
USER app
WORKDIR /home/app
COPY --from=builder /out/app /home/app/app
ENV PORT=8080
EXPOSE 8080
CMD ["/home/app/app"]
