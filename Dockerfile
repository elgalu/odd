# vim:syntax=dockerfile
FROM zalando/openjdk:8u40-b09-2
MAINTAINER Henning Jacobs <henning.jacobs@zalando.de>

RUN apt-get update -y
RUN apt-get install -y supervisor openssh-server python-setuptools python3-requests python3-yaml

RUN mkdir -p -m0755 /var/run/sshd

COPY supervisord.conf /etc/supervisord.conf
COPY sshd_config /etc/ssh/sshd_config
COPY sudoers /etc/sudoers
COPY run.sh /run.sh

# setup SSH Access Granting Service
RUN curl -o /usr/local/bin/grant-ssh-access-forced-command.py \
    https://raw.githubusercontent.com/zalando/ssh-access-granting-service/master/grant-ssh-access-forced-command.py
RUN chmod +x /usr/local/bin/grant-ssh-access-forced-command.py
RUN useradd --create-home --user-group --groups adm granting-service
RUN mkdir ~granting-service/.ssh/
RUN echo 'PLACEHOLDER' > ~granting-service/.ssh/authorized_keys
RUN chown granting-service:root -R ~granting-service
RUN chmod 0700 ~granting-service
RUN chmod 0700 ~granting-service/.ssh
RUN chmod 0400 ~granting-service/.ssh/authorized_keys

EXPOSE 22

CMD /run.sh