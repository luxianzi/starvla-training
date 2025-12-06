# Base image
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 AS intermediate

# Initialize basic dependencies and user
COPY ./files/init-dep.sh ./files/init-user.sh /usr/bin/
ARG UID=1000
ARG USERNAME=worker
RUN init-dep.sh && rm /usr/bin/init-dep.sh && init-user.sh && rm /usr/bin/init-user.sh

# Initialize SSH server for connections when running on a remote server
# Note: we bring up sshd in entrypoint.sh, if we need to bring up other services, please edit the entrypoint.sh accordingly
COPY ./files/init-ssh.sh /usr/bin/
COPY ./files/entrypoint.sh /
RUN init-ssh.sh && rm /usr/bin/init-ssh.sh
EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]

# Change to the regular user for initializing dependencies
USER $USERNAME
WORKDIR /home/$USERNAME/

# Install miniforge to provide conda with a business-ready license
COPY ./files/init-conda.sh /home/$USERNAME/
RUN /home/$USERNAME/init-conda.sh && rm /home/$USERNAME/init-conda.sh

# Init training dependencies
COPY ./files/internvla-m1.yml /home/$USERNAME/
COPY ./files/init-training.sh /home/$USERNAME/
RUN /home/$USERNAME/init-training.sh && rm /home/$USERNAME/init-training.sh && rm /home/$USERNAME/internvla-m1.yml

# Switch back to root to make sure we have the privilege to invoke entrypoint script
USER root
