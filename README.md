StarVLA Training Container
============================

* Docker GPU Support

  GPU support must be enabled in Docker to correctly pass the GPU through to the container. This is accomplished by installing the NVIDIA Container Toolkit (formerly NVIDIA Docker). For more details, see the following:

  ```
  sudo apt update
  sudo apt install curl gnupg2
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
      && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
      sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
      sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
  sudo apt update
  sudo apt install nvidia-container-toolkit  nvidia-container-toolkit-base  libnvidia-container-tools  libnvidia-container1
  sudo nvidia-ctk runtime configure --runtime=docker
  sudo systemctl restart docker
  ```

* Build

  We strongly recommend adding your user to the `docker` group.

  `sudo usermod -aGdocker $USER`

  After doing so, you can run all the Docker commands without using `sudo`.

  `docker buildx . -t <Container Tag>`

* Run

  Typically, you need to mount your training code and data as a volume. Assuming they are located in the `<Share Directory>`, you can mount them using the `-v` option in the `docker run` command:

  `docker run -v <Share Directory>:/home/worker/share -it --rm --gpus all <Container Tag>`

  The password for the `worker` user is `worker`, in case you need to run commands with `sudo`.

* Switch To the Traning Environment

  `conda activate startvla`

* Remote Connection

  This container includes a built-in SSH server. To enable SSH access, expose the SSH port by adding a port-forwarding option to your `docker run` command, and provide an `SSH_PUBLIC_KEY` environment variable. The entrypoint script will automatically install the key inside the container.

  ```
  docker run \
    -e SSH_PUBLIC_KEY="<ssh-rsa AAA...>" \
    -p <Port number>:22 \
    -v <Share Directory>:/home/worker/share \
    -it --rm --gpus all <Container Tag>
  ```

  On Linux, you can generate an SSH key pair using ssh-keygen.

  ```
  ssh-keygen -t ed25519 -f <Key Storage Path>/<Key Name> -C "<Some Comment>"
  ```

  The content of `SSH_PUBLIC_KEY` can be found in the file `<Key Storage Path>/<Key Name>.pub`, and the file `<Key Storage Path>/<Key Name>` is the corresponding private key for the SSH client. You can connect to the container over SSH using `<Docker Host IP>:<Port number>` and username `worker`.

  ```
  ssh -i <Key Storage Path>/<Key Name> -p 2222 worker@<Docker Host IP>
  ```

* Using Dev Containers in VSCode

  You can open the project inside a container by searching for “Dev Containers: Open Folder in Container” from the Command Palette (Ctrl + Shift + P) and selecting the root of the Git repository.

  Note: the container may take some time to build the first time it is opened

  By default, Dev Containers override the container’s entrypoint. Each time you open a terminal in VS Code, it will start as the root user. If you prefer to use the `worker` user instead, you can set "remoteUser" in `.devcontainer/devcontainer.json` to enforce this.

  To pass all GPUs to the container, include a runArgs section in your `.devcontainer/devcontainer.json` file and set it to `["--gpus", "all"]`.

  You can also choose the Python executable from the created conda environment by searching for “Python: Select Interpreter” in the Command Palette.

  If you are using VS Code on Windows but connecting docker containers on WSL, you need to open the folder in WSL before open it again in Dev Containers.

* AWS CLI

  This container includes the AWS CLI, which you can use to synchronize training data from Amazon S3. You can configure it interactively as needed, or supply credentials and the AWS region, via environment variables by passing `AWS_KEY_ID`, `AWS_KEY`, and `AWS_REGION` to your `docker run` command.