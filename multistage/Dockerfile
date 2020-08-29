FROM golang:1.7.3 as build
WORKDIR /build
COPY main.go .
RUN CFO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .
CMD ["./main"]

FROM alpine:latest
WORKDIR /app/
COPY --from=build /build/main .
CMD ["./main"]