# Base image
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu24.04 AS intermediate

# Initialize basic dependencies and user
COPY ./files/init-dep.sh ./files/init-user.sh /usr/bin/
ARG UID=1000
ARG USERNAME=worker
RUN init-dep.sh && rm /usr/bin/init-dep.sh && init-user.sh && rm /usr/bin/init-user.sh

# Initialize SSH server for connections when running on a remote server
COPY ./files/init-ssh.sh /usr/bin/
COPY ./files/entrypoint.sh /
RUN init-ssh.sh && rm /usr/bin/init-ssh.sh
EXPOSE 22

# Initialize AWS CLI for synchronizing data
COPY ./files/init-aws-cli.sh /usr/bin
RUN init-aws-cli.sh && rm /usr/bin/init-aws-cli.sh

# Note: You can pass the SSH public key and AWS access key ID and key as environment variables when running the
#       container.
# Note: We bring up sshd in entrypoint.sh, if we need to bring up other services, please edit the entrypoint.sh
#       accordingly.
ENTRYPOINT ["/entrypoint.sh"]

# Change to the regular user for initializing dependencies
USER $USERNAME
WORKDIR /home/$USERNAME/

# Install miniforge to provide conda with a business-ready license
COPY ./files/init-conda.sh /home/$USERNAME/
RUN /home/$USERNAME/init-conda.sh && rm /home/$USERNAME/init-conda.sh

# Init training dependencies
COPY ./files/starvla.yml /home/$USERNAME/
COPY ./files/init-training-env.sh /home/$USERNAME/
RUN /home/$USERNAME/init-training-env.sh && rm /home/$USERNAME/init-training-env.sh && rm /home/$USERNAME/starvla.yml

# Switch back to root to make sure we have the privilege to invoke entrypoint script
USER root
