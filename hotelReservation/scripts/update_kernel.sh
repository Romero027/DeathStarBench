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

function update_kernel() {
    KERNEL_VERSION=$1
    IP=$2
    NUMBER_OF_CORES=$3
ssh $2 > /dev/null 2>&1 << eeooff
    wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$KERNEL_VERSION.tar.xz
    unxz -v linux-$KERNEL_VERSION.tar.xz
    tar xvf linux-$KERNEL_VERSION.tar
eeooff

scp .config $2:~/linux-$KERNEL_VERSION

ssh $2 > /dev/null 2>&1 << eeooff
    cd linux-$KERNEL_VERSION
    sudo apt-get update
    sudo apt-get install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev
    sudo make menuconfig
    # add CONFIG_SYSTEM_TRUSTED_KEYS="" to .config
    sudo make -j $(nproc)
    sudo make modules_install
    sudo make install
    sudo update-initramfs -c -k $KERNEL_VERSION
    
    sudo update-grub

    cd tools/perf
    sudo make -j $(nproc)
    sudo cp perf /usr/bin/
    sudo reboot
eeooff
}

update_kernel 5.10.76 xzhu@clnode074.clemson.cloudlab.us
