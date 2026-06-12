# Multi-stage build: compile in builder, ship from minimal alpine
FROM golang:1.22-alpine AS builder
WORKDIR /src
COPY go.mod ./
# go.sum is generated on first build (not committed; see README)
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -trimpath -ldflags="-s -w" -o /out/app .

FROM alpine:3.20
RUN adduser -D -u 10001 app
USER app
WORKDIR /home/app
COPY --from=builder /out/app /home/app/app
ENV PORT=8080
EXPOSE 8080
CMD ["/home/app/app"]
