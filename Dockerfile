FROM debian:jessie

ENV NODE_ENV production

RUN apt-get update

RUN apt-get install -y curl git graphicsmagick unzip sendmail ruby ruby-dev bundler python g++ make

# Install node 0.10 from nodesource
RUN curl -sL https://deb.nodesource.com/setup_0.10 | bash -
RUN apt-get install -y nodejs

RUN mkdir /opt/popit
WORKDIR /opt/popit
ADD . /opt/popit

RUN gem install sass --version=3.2.14 --no-rdoc --no-ri
RUN gem install compass --version=0.12.2 --no-rdoc --no-ri

RUN make
RUN make public-production

ENTRYPOINT ["npm"]
CMD ["start"]
