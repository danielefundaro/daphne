###########
# BUILDER #
###########

FROM python:3.9.11-alpine as builder

RUN apk update
RUN apk upgrade
RUN apk add gcc musl-dev python3-dev libffi-dev openssl-dev cargo

# install dependencies
RUN pip install -U pip
COPY ./requirements.txt .
RUN pip wheel --no-cache-dir --no-deps --wheel-dir /wheels -r requirements.txt


#########
# FINAL #
#########

FROM python:3.9.11-alpine

# create the app user
RUN addgroup -S daphne-user && adduser -S daphne-user -G daphne-user

# create the appropriate directories
ENV HOME=/home/daphne-user
ENV APP_HOME=/home/daphne-user/web
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

# install dependencies
COPY --from=builder /wheels /wheels
RUN pip install --no-cache /wheels/*
RUN rm -r /wheels

# chown all the files to the app user
RUN chown -R daphne-user:daphne-user $APP_HOME

# change to the app user
USER daphne-user
