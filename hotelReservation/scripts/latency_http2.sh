pid=${1}
envoy_path=${2}

python3 /mnt/bcc/tools/funclatency.py ${envoy_path}:*nghttp2_session_mem_recv* -d ${a} > ${pid}_envoy_userspace_$i.txt
python3 /mnt/bcc/tools/funclatency.py -p $pid do_readv -d 20 > ${pid}_do_readv_$i.txt
python3 /mnt/bcc/tools/funclatency.py -p $pid do_writev -d 20 > ${pid}_do_writev_$i.txt
python3 /mnt/bcc/tools/funclatency.py -p $pid process_backlog -d 20 > ${pid}_process_backlog_$i.txt
python3 /mnt/bcc/tools/funclatency.py -p $pid ep_send_events_proc -d 20 > ${pid}__epoll_$i.txt
