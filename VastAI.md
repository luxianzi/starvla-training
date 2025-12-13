Running with VastAI
===================

* VastAI

  [Vast.ai](https://vast.ai) is an online marketplace for renting and offering GPU compute, mainly used for AI, machine learning, deep learning, and rendering workloads.

* Getting VastAI CLI and configure the API Key

  Getting VastAI:

  ```
  mkdir -p ~/.local/bin
  wget https://raw.githubusercontent.com/vast-ai/vast-python/master/vast.py -O ~/.local/bin/vastai
  chmod +x ~/.local/bin/vastai
  ```

  To create an API key, log in to the VastAI console. In the left navigation menu, click "Keys", then open the "API Keys" tab and click "New". In the pop-up window, enter a "Name" for the key and configure the permissions in the "Standard" tab, then click "Save". In the next pop-up window, copy the API key and store it securely.

  After getting the API key, you can configure the VastAI CLI:

  ```
  vastai set api-key xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
  ```

* Search For Available Machines

  You can use the `vastai search offers` command to search for available machines. E.g. if your target is 4x RTX 5090, CUDA Version > 12.8, internet download and upload speed > 1Gbps, PCIE generation > 5.0, and sort by price, you can run:

  ```
  vastai search offers -o dph gpu_name=RTX_5090 \
                              num_gpus=4 \
                              'cuda_vers >= 12.8' \
                              'inet_down >= 1000' \
                              'inet_up >= 1000' \
                              'pci_gen >= 5'
  ```

  You will get something like:

  ```
  ID        CUDA   N  Model     PCIE  cpu_ghz  vCPUs    RAM  VRAM  Disk  $/hr    DLP    DLP/$   score  NV Driver   Net_up  Net_down  R     Max_Days  mach_id  status    host_id  ports  country
  28481728  12.8  4x  RTX_5090  54.2  3.1      51.2   309.5  32.6  4305  1.8681  587.3  314.37  405.0  570.181     6765.7  3886.0    99.2  114.8     41437    verified  60400    19999  Texas,_US
  28324445  12.8  4x  RTX_5090  54.0  3.1      64.0   386.8  32.6  2870  2.0281  644.3  317.71  417.5  570.169     7099.7  3731.2    99.3  158.2     40291    verified  60400    24999  Texas,_US
  28273725  13.0  4x  RTX_5090  26.9  2.4      96.0   193.2  32.6  1362  2.0774  481.5  231.76  310.9  580.95.05   6554.2  7531.4    99.5  181.7     44827    verified  208817   499    Ontario,_CA
  28737216  12.9  4x  RTX_5090  54.1  2.2      170.7  343.6  32.6  3996  2.1356  645.2  302.09  386.7  575.64.05   6205.3  6456.6    99.1  179.7     40584    verified  54667    399    New_York,_US
  28761955  13.0  4x  RTX_5090  54.1  3.1      256.0  515.4  32.6  5558  2.1356  645.6  302.31  382.6  580.105.08  5426.5  6606.8    99.7  150.2     8990     verified  54667    498    New_York,_US
  28676506  13.0  4x  RTX_5090  54.2  2.4      192.0  773.8  32.6  1586  2.2414  645.6  288.04  366.4  580.95.05   7523.4  4018.1    99.4  64.4      42795    verified  60400    19999  Texas,_US
  27137978  12.8  4x  RTX_5090  54.2  3.1      128.0  580.3  32.6  3127  2.4014  553.5  230.50  285.5  570.195.03  3289.2  4934.2    99.7  130.9     45707    verified  1647     149    Iceland,_IS
  25531503  12.9  4x  RTX_5090  49.7  2.6      96.0   386.8  32.6  2558  2.4547  629.0  256.26  321.4  575.57.08   3525.3  3579.4    99.9  322.2     8461     verified  18       124    Alberta,_CA
  ```

  You can choose one from the list and mark the `<OFFER ID>`.

* Create an Instance

  To create an instance, you need a container registry and tag that are accessible over the internet. You must also provide the environment variables to be passed to the container, along with the disk size in GB and the command to run. For a container built from this repository:

  ```
  vastai create instance <OFFER_ID> --image ghcr.io/luxianzi/starvla-training:e7792247d57c9c890d89d7a3316ceb825db44341
                                    --env '-p 22:22 -e SSH_PUBLIC_KEY="ssh-rsa AAAA..."'
                                    --disk 32
                                    --args /usr/bin/sleep infinity
  ```

  Please note that you must pass /usr/bin/sleep infinity to keep the container running. The terminal output will include a `<Contract ID>`.

  ```
  Started. {'success': True, 'new_contract': <Instance ID>}
  ```

  You can also get this `<Instance ID>` by the `show instances` command.

  ```
  # vastai show instances
  ID        Machine  Status   Num  Model     Util. %  vCPUs    RAM  Storage  SSH Addr  SSH Port  $/hr    Image                                                                         Net up  Net down  R     Label  age(hours)  uptime(mins)
  28785454  41437    running   1x  RTX_5090  -        12.8   773.7  32       -         -         0.4756  ghcr.io/luxianzi/internvla-training:e7792247d57c9c890d89d7a3316ceb825db44341  6765.7  3886.0    99.3  -      0.08        -
  ```

  The number `28785454` above is the `<Instance ID>`. When the status turns to "runing", you can get the server IP address and port as the following.

  ```
  vastai show instance <Instance ID> --raw | jq -r '.public_ipaddr'
  vastai show instance <Instance ID> --raw | jq -r '.ports."22/tcp"[0].HostPort'
  ```

  Then you can connect to the instance using the IP address and port.

* Synchronizing Data with Amazon S3

  The VastAI CLI provides functionality to synchronize data between an Amazon S3 storage bucket and an instance. Before using this feature, you must configure the S3 connection via the web UI and obtain the `<Connection ID>`.

  ```
  # vastai show connections
  ID     NAME                Cloud Type
  34131  some-training-data  s3
  ```

  The number `34131` above is the `<Connection ID>`.

  To copy data between the S3 and the instance, you must also provide the `<S3 Bucket Path>`, `<Instance Path>`, `<Instance ID>` and `<Transfer Type>`.

  Copy from the S3 to the instance, you can run the following command.

  ```
  vastai cloud copy --src <S3 Bucket Path> --dst <Instance Path> --instance <Instance ID> --connection <Connection ID> --transfer "Cloud To Instance"
  ```

  Copy from the instance to the S3, you can run the following command.

  ```
  vastai cloud copy --src <Instance Path> --dst  <S3 Bucket Path> --instance <Instance ID> --connection <Connection ID> --transfer "Instance To Cloud"
  ```

  For example:

  ```
  vastai cloud copy --src /some-training-data/ --dst /home/worker/share --instance 28791005 --connection 34131 --transfer "Cloud To Instance"
  ```

  The command above only start the copy operation, you can check the copy progress using the following command.

  ```
  vastai show instance <Instance ID> --raw | jq -r ".status_msg"
  ```

  You will see the message: "Cloud Copy Operation Complete", when the copy is done.

* Handle with Unstable Network Connection

  You will need to run the training with `nohup` command and ends with a `&` symbol. `nohup` keeps the command running even the SSH connection breaks. `&` symbol sends the command to the background. For example:

  ```
  nohup accelerate launch --config-file config.yaml --num_processes 1 train.py --config_yaml training.yaml > log.txt &
  ```

  You can find the training log in log.txt.

* Destroy The Instance

  All instances on VastAI are on-demand, do not forget to destroy the instance when your work is done. Storage charge will still apply when the instance is stopped.

  ```
  vastai destory instance <Instance ID>
  ```

For detailed instructions on using the CLI, see the [VastAI CLI Documents](https://docs.vast.ai/cli/get-started)
