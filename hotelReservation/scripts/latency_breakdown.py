import os
import re
import docker
import argparse
import subprocess


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--proxy', type=str, default='tcp', help='proxy type (tcp, http or grpc')
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
            proxy_dict[app_name] = {}
            proxy_dict[app_name]['id'] = container.short_id
            proxy_dict[app_name]['envoy_binary_path'] = \
                container.attrs['GraphDriver']['Data']['MergedDir'] + '/usr/local/bin/envoy'
            processes = container.top()['Processes']
            for p in processes:
                if '/usr/local/bin/envoy' in p[7]:
                    proxy_dict[app_name]['envoy_pid'] = p[1]
    return proxy_dict


def run_funclatency(func, duration, pid=None):

    if pid:
        result = subprocess.run(['python3', '/mnt/bcc/tools/funclatency.py', '-p '+str(pid), func, '-d '+str(duration)], stdout=subprocess.PIPE)
    else:
        result = subprocess.run(['python3', '/mnt/bcc/tools/funclatency.py', func, '-d '+str(duration)], stdout=subprocess.PIPE)

    # extract avg latency from output    
    result = result.stdout.decode("utf-8").split('\n')[-4]
    
    # parse avg latency string
    avg_latency = re.findall(r'\d+', result)[0]

    return avg_latency

# write, read, loopback, epoll, and Envoy userspace
def run_latency_breakdown(app, envoy_process, duration):
    print("Running " + str(app) + " latency breakdown...")
    breakdown = {}
    breakdown['loopback_latency'] = run_funclatency('process_backlog', duration, envoy_process['envoy_pid'])
    breakdown['read_latency'] = run_funclatency('do_readv', duration, envoy_process['envoy_pid'])
    breakdown['write_latency'] = run_funclatency('do_writev', duration, envoy_process['envoy_pid'])
    breakdown['epoll_latency'] = run_funclatency('ep_send_events_proc', duration, envoy_process['envoy_pid'])
    breakdown['envoy_latency'] = run_funclatency(envoy_process['envoy_binary_path']+':*onReadReady*', duration)

    return breakdown

if __name__ == '__main__':
    args = parse_args()

    envoy_info = get_envoy_info()
    print(envoy_info)

    result = {}
    for app, envoy_process in envoy_info.items():
        result[app] = run_latency_breakdown(app, envoy_process, 45)
    print(result)