FROM alpine
ADD . /Log4jCenter
RUN apk update && \
    apk add git openjdk11 py3-pip python3 maven 
WORKDIR /Log4jCenter
RUN mvn package -f /Log4jCenter/utils/rogue-jndi/
RUN pip3 install -r requirements.txt
ENTRYPOINT ["python3","exploit.py"]
