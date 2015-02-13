FROM debian:jessie
MAINTAINER Carles Amigó, fr3nd@fr3nd.net

ENV PUPPET_VERSION 3.7.1
ENV FACTER_VERSION 2.4.1
ENV FLEET_VERSION 0.9.0
ENV ETCD_VERSION 2.0.2
ENV ANSIBLE_VERSION 1.8.2

RUN apt-get update && apt-get install -y \
      curl \
      git \
      golang \
      python-dev \
      python-pip \
      ruby

# Install fleetctl
WORKDIR /tmp
RUN git clone https://github.com/coreos/fleet.git
WORKDIR /tmp/fleet
RUN git checkout v$FLEET_VERSION
RUN ./build
RUN cp bin/fleetctl /usr/bin/
WORKDIR /tmp
RUN rm -rf fleet

# Install etcdctl
WORKDIR /tmp
RUN curl -L https://github.com/coreos/etcd/releases/download/v$ETCD_VERSION/etcd-v$ETCD_VERSION-linux-amd64.tar.gz | tar xvz
RUN cp etcd-v$ETCD_VERSION-linux-amd64/etcdctl /usr/bin/

# Install puppet
WORKDIR /tmp
RUN echo "gem: --bindir /usr/bin --no-ri --no-rdoc" > ~/.gemrc
RUN gem install facter -v $FACTER_VERSION
RUN gem install puppet -v $PUPPET_VERSION
#RUN puppet resource group puppet ensure=present
#RUN puppet resource user puppet ensure=present gid=puppet shell='/usr/sbin/nologin'
RUN mkdir -p /etc/puppet/manifests /etc/puppet/modules
ADD puppet.conf /etc/puppet/puppet.conf
RUN gem install r10k

# Install ansible
#WORKDIR /tmp
#RUN pip install ansible==$ANSIBLE_VERSION --install-option="--install-scripts=/usr/bin"

WORKDIR /

VOLUME /var/tmp/puppet_fleet
