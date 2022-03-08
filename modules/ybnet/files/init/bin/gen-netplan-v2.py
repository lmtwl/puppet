import os
import yaml
import psutil
'''
Netplan配置文件生成
1、适配所有机器
2、带vlan配置的机器除外
'''
NETPLAN_PATH = '/etc/netplan'
TABLE_TWO_IPS = ['120.26.61.146', '47.110.185.59', '106.11.40.32', '115.29.203.237', '47.96.28.148', '1.14.95.74', '121.40.175.167', '114.114.114.114', '101.132.115.68', '47.100.69.96', '106.15.3.165', '139.196.172.164']
class NetworkInterface:
    '''网络接口类'''
    def __init__(self, name:str, gateway4:str, macaddress: str,  routing_table:int = 0, *ip_v4) -> None:
        self.name = name
        self.gateway4 = gateway4
        self.macaddress = macaddress
        self.routing_table = routing_table
        self.ip_v4 = ip_v4
        

    #输出为netplan风格的dict
    def to_netplan_dict(self) -> dict:
        res = {}
        res['addresses'] = list(self.ip_v4)
        res['set-name'] = self.name
        res['match'] = {'macaddress': self.macaddress}
        if self.gateway4:
            routing_policy = []
            for ip in self.ip_v4:
                routing_policy.append({
                    'from': ip,
                    'table': self.routing_table,
                    'priority': 32750
                })
                if self.routing_table == 2:
                    for ip_t2 in TABLE_TWO_IPS:
                        routing_policy.append({
                            'to': ip_t2,
                            'table': self.routing_table,
                            'priority': 32700
                        })
            res['routing-policy'] = routing_policy
            res['routes'] = [{
                'to': '0.0.0.0/0',
                'via': self.gateway4,
                'table': self.routing_table
                }]
        return res

class Netplan:
    '''网卡配置类'''
    def __init__(self, path: str, interfaces: list) -> None:
        self.path = path
        self.interfaces = interfaces
    
    def to_netplan_dict(self) -> dict:
        network = {}
        network['version'] = 2
        if self.interfaces:
            network['ethernets'] = { interface.name:interface.to_netplan_dict() for interface in self.interfaces }
        return {
            'network': network
        }

def exchange_netmask(netmask):
  return sum([bin(int(i)).count('1') for i in netmask.split('.')])


def gen_netplan():
    delete_renderer_data = {}
    filenames = os.listdir(NETPLAN_PATH)
    interfaces_filename = ''
    ethernets = None
    real_if_names = None
    net_ifs = psutil.net_if_addrs()
    #轮询文件
    for filename in filenames:
        with open(os.path.join(NETPLAN_PATH, filename), 'r') as file:
            configuration = yaml.safe_load(file).get('network')
            if not configuration:
                continue
        if 'ethernets' in configuration.keys():
            ethernets = configuration.get('ethernets')
            #从原始的配置文件取到的网卡，和实际启用的网卡取交集
            tmp_if_names = ethernets.keys() & net_ifs.keys()
            #如果有说明这个文件是生效的文件
            if len(tmp_if_names):
                #经过了排序之后，会变成eth0-eth?这种顺序
                real_if_names = sorted(tmp_if_names)
                interfaces_filename = filename
        #处理renderer为NetworkManager的情况
        if 'renderer' in configuration.keys() and 'ethernets' not in configuration.keys():
            configuration.pop('renderer')
            delete_renderer_data[filename] = {'network': configuration}
    network_interfaces = []
    for idx, interface_name in enumerate(real_if_names):
        #snicaddr(family=<AddressFamily.AF_INET: 2>, address='192.168.66.23', netmask='255.255.254.0', broadcast='192.168.67.255', ptp=None)
        #snic(family=<AddressFamily.AF_PACKET: 17>, address='52:54:00:7f:e9:f4', netmask=None, broadcast='ff:ff:ff:ff:ff:ff', ptp=None)]
        snicaddrs = net_ifs.get(interface_name)
        interfaces_ipv4 = []
        macaddress = ''
        for snicaddr in snicaddrs:
            if snicaddr.family.name == 'AF_INET' and snicaddr.family.value == 2:
                netmask_int = exchange_netmask(snicaddr.netmask)
                interfaces_ipv4.append(snicaddr.address + '/' + str(netmask_int))
            
            if snicaddr.family.name == 'AF_PACKET' and snicaddr.family.value == 17:
                macaddress = snicaddr.address
        cmd = 'ip route list table all | grep default | grep ' + interface_name
        r = os.popen(cmd).read().strip().split()
        if not r:
            continue
        gateway4 = r[2]
        table = idx + 2
        network_interface = NetworkInterface(interface_name, gateway4, macaddress,  table, *tuple(interfaces_ipv4))
        network_interfaces.append(network_interface)
    return Netplan(os.path.join(NETPLAN_PATH, interfaces_filename), network_interfaces), delete_renderer_data

def main():
    netplan, delete_renderer_data = gen_netplan()
    if not netplan:
        print('Netplan配置中有vlan配置，请手动编写策略路由！')
    with open(netplan.path, 'w') as file:
        yaml.safe_dump(netplan.to_netplan_dict(), file, indent=4, sort_keys=True)
    os.popen('chattr +i ' + netplan.path)
    for k,v in delete_renderer_data.items():
        path = os.path.join(NETPLAN_PATH, k)
        with open(path, 'w') as file:
            yaml.safe_dump(v, file, indent=4, sort_keys=True)
        os.popen('chattr +i ' + path)

if __name__ == '__main__':
    main()

