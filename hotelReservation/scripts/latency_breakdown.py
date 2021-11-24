import os
import re
import docker
import argparse
import subprocess


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--proxy', type=str, default='tcp', help='proxy type (tcp, http or grpc')
    parser.add_argument("-v", "--verbose", action="store_true", help="print the command executed (for debugging purposes)")
    return parser.parse_args()


def get_envoy_info():
    proxy_dict = {}
    client = docker.from_env()
    containers = client.containers.list()
    # Get container info
    for c in containers:
        container = client.containers.get(c.short_id)
        container_name = container.attrs['Name']
        if 'istio-proxy' in container_name:
            app_name = container_name.split('_')[2].split('-')[0]
            if app_name == "istio":
                continue
            proxy_dict[app_name] = {}
            proxy_dict[app_name]['id'] = container.short_id
            processes = container.top()['Processes']
            for p in processes:
                if '/usr/local/bin/envoy' in p[7]:
                    proxy_dict[app_name]['envoy_pid'] = p[1]
            proxy_dict[app_name]['envoy_binary_path'] = "/proc/PID/root/usr/local/bin/envoy".replace("PID", proxy_dict[app_name]['envoy_pid'])
    return proxy_dict


def run_funclatency(func, duration, pid=None, delta_min=0):
    # funclatency_path = "/mnt/bcc/tools/funclatency.py"
    funclatency_path = "./funclatency.py"

    cmd = ['python3', funclatency_path, '-p '+str(pid), func, '-d '+str(duration), '-t '+str(delta_min)]
    print("Running cmd: " + " ".join(cmd))
    result = subprocess.run(cmd, stdout=subprocess.PIPE)

    # extract avg latency from output    
    result = result.stdout.decode("utf-8").split('\n')[-4]
    
    # parse avg latency string
    avg_latency = re.findall(r'\d+', result)[0]

    return int(avg_latency)

# write, read, loopback, epoll, and Envoy userspace
def run_tcp_proxy_latency_breakdown(app, envoy_process, duration):
    print("Running " + str(app) + " latency breakdown...")
    breakdown = {}
    breakdown['loopback_latency'] = run_funclatency('process_backlog', duration, envoy_process['envoy_pid'])
    breakdown['read_latency'] = run_funclatency('do_readv', duration, envoy_process['envoy_pid'])
    breakdown['write_latency'] = run_funclatency('do_writev', duration, envoy_process['envoy_pid']) - breakdown['loopback_latency']
    breakdown['epoll_latency'] = run_funclatency('ep_send_events_proc', duration, envoy_process['envoy_pid'])
    breakdown['envoy_latency'] = run_funclatency(envoy_process['envoy_binary_path']+':*onReadReady*', 
                        duration, envoy_process['envoy_pid'], delta_min=breakdown['read_latency']) - breakdown['read_latency']
    breakdown['envoy_latency'] += run_funclatency(envoy_process['envoy_binary_path']+':*onWriteReady*', 
                        duration, envoy_process['envoy_pid'], delta_min=breakdown['write_latency']) - breakdown['write_latency']

    return breakdown

def run_http_proxy_latency_breakdown(app, envoy_process, duration):
    print("Running " + str(app) + " latency breakdown...")
    breakdown = {}
    breakdown['loopback_latency'] = run_funclatency('process_backlog', duration, envoy_process['envoy_pid'])
    breakdown['read_latency'] = run_funclatency('do_readv', duration, envoy_process['envoy_pid'])
    breakdown['write_latency'] = run_funclatency('do_writev', duration, envoy_process['envoy_pid']) - breakdown['loopback_latency']
    breakdown['epoll_latency'] = run_funclatency('ep_send_events_proc', duration, envoy_process['envoy_pid'])
    http2_latency = breakdown['envoy_latency'] = run_funclatency(envoy_process['envoy_binary_path']+':*nghttp2_session_mem_recv*', duration, envoy_process['envoy_pid'])
    http_latency = breakdown['envoy_latency'] = run_funclatency(envoy_process['envoy_binary_path']+':*http_parser_execute*', duration, envoy_process['envoy_pid'])
    breakdown['envoy_latency'] = run_funclatency(envoy_process['envoy_binary_path']+':*onReadReady*', 
                        duration, envoy_process['envoy_pid'], delta_min=max(http_latency, http2_latency)) - breakdown['read_latency']
    breakdown['envoy_latency'] += run_funclatency(envoy_process['envoy_binary_path']+':*onWriteReady*', 
                        duration, envoy_process['envoy_pid'], delta_min=breakdown['write_latency']) - breakdown['write_latency']

if __name__ == '__main__':
    args = parse_args()

    envoy_info = get_envoy_info()
    print(envoy_info)

    result = {}
    if envoy_info:
        for app, envoy_process in envoy_info.items():
            if args.proxy == "tcp":
                print("Running breakdown experiment for TCP proxy...")
                result[app] = run_tcp_proxy_latency_breakdown(app, envoy_process, 15)
            elif args.proxy == "http":
                print("Running breakdown experiment for HTTP proxy...")
                result[app] = run_http_proxy_latency_breakdown(app, envoy_process, 15)

    print(result)