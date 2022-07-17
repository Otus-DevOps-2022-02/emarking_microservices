FROM ubuntu:16.04

#installing software
RUN apt-get update
RUN apt-get install -y  software-properties-common mongodb-server ruby-full ruby-dev build-essential git
RUN gem install bundler
RUN git clone -b monolith https://github.com/express42/reddit.git

#Copy config files to container

COPY mongod.conf /etc/mongod.conf
COPY db_config /reddit/db_config
COPY start.sh /start.sh

# Install dep and run script
RUN cd /reddit && bundle install
RUN chmod 0777 /start.sh

CMD ["/start.sh"]