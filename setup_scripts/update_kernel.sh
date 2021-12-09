## modify kernel config

# CONFIG_BPF=y
# CONFIG_BPF_SYSCALL=y
# CONFIG_NET_CLS_BPF=y
# CONFIG_BPF_JIT=y
# CONFIG_NET_CLS_ACT=y
# CONFIG_NET_SCH_INGRESS=y
# CONFIG_CRYPTO_SHA1=y
# CONFIG_CRYPTO_USER_API_HASH=y
# CONFIG_CGROUPS=y
# CONFIG_CGROUP_BPF=y
# sed -i 's/CONFIG_BPF=y/new-text/g' .config



wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.10.76.tar.xz
unxz -v linux-5.10.76.tar.xz
tar xvf linux-5.10.76.tar

cd linux-5.10.76
sudo apt-get update
sudo apt-get install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev
sudo make menuconfig
# add CONFIG_SYSTEM_TRUSTED_KEYS="" to .config
#echo CONFIG_SYSTEM_TRUSTED_KEYS="" >> .config
sudo make -j $(nproc)
sudo make modules_install
sudo make install
sudo update-initramfs -c -k 5.10.76

sudo update-grub

cd tools/perf
sudo make -j $(nproc)
sudo cp perf /usr/bin/
sudo reboot

# install BCC
# For 18.04
sudo apt-get -y install bison build-essential cmake flex git libedit-dev \
  libllvm6.0 llvm-6.0-dev libclang-6.0-dev python zlib1g-dev libelf-dev libfl-dev python3-distutils

# For 20.04.1
sudo apt install -y bison build-essential cmake flex git libedit-dev \
  libllvm7 llvm-7-dev libclang-7-dev python zlib1g-dev libelf-dev libfl-dev python3-distutils

git clone https://github.com/iovisor/bcc.git
mkdir bcc/build; cd bcc/build
cmake ..
make
sudo make install
cmake -DPYTHON_CMD=python3 .. # build python3 binding
pushd src/python/
make
sudo make install
popd
