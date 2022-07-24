FROM ubuntu:16.04

WORKDIR /reddit
ADD . .

#installing software
RUN apt-get update && \
    apt-get install -y  software-properties-common mongodb-server ruby-full ruby-dev build-essential git && \
    gem install bundler && \
    gem install mongo


#Copy config files to container

COPY mongod.conf /etc/mongod.conf

# Install dep and run script
RUN cd /reddit && bundle install && chmod 0777 /start.sh

CMD ["/start.sh"]
