FROM golang:1.14
# set the working directory in the container to /app
WORKDIR /app
# add the current directory to the container as /app
ADD app.go /app
ADD out/server /app/server
COPY ./harden.sh .
RUN chmod +x harden.sh && \
    /bin/sh harden.sh && \
    /bin/rm harden.sh
RUN chown appuser:appuser /app/server/* && go build app.go && rm -f /app/app.go
# unblock port 8080 for the Flask app to run on
EXPOSE 8080

USER appuser
# execute the Flask app
CMD ["./app"]
