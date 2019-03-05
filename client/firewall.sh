#!/bin/bash
## Install: Firewall ## 

# Pre-Requirement (Save iptables on reboot)
sudo apt-get install -y iptables-persistent

# A: Flush IPTables (Flush Rule, Remove Custom Tables, Reset Counter) #
sudo iptables -F
sudo iptables -X
sudo iptables -Z

# B: Flush NAT, Mangle, Raw, Security Tables (Flush Rule, Remove Custom Tables, Reset Counter) #
sudo iptables -t nat -F
sudo iptables -t nat -X
sudo iptables -t nat -Z
sudo iptables -t mangle -F
sudo iptables -t mangle -X
sudo iptables -t mangle -Z
sudo iptables -t raw -F
sudo iptables -t raw -X
sudo iptables -t raw -Z
sudo iptables -t security -F
sudo iptables -t security -X
sudo iptables -t security -Z

# C: Block Against Local Addressing #
sudo iptables -t raw -I PREROUTING -m rpfilter --invert -j DROP

# D: Setup Default Chains #
# (Input =  Drop, Forward = Drop, Output = Allow) #
sudo iptables -P INPUT DROP
sudo iptables -P FORWARD DROP
sudo iptables -P OUTPUT ACCEPT

# E: Setup Basic Security #
# Drop Invalid Packet States #
sudo iptables -A INPUT -m state --state INVALID -j DROP -m comment --comment   "Drop: Input State: InValid"
sudo iptables -A FORWARD -m state --state INVALID -j DROP -m comment --comment "Drop: Forward State: InValid"
sudo iptables -A OUTPUT -m state --state INVALID -j DROP -m comment --comment  "Drop: Output State: InValid"  

# Drop Bogus TCP Requests #
sudo iptables -A INPUT -p tcp --tcp-flags FIN,ACK FIN -j DROP -m comment --comment "Drop: FIN,ACK,FIN"
sudo iptables -A INPUT -p tcp --tcp-flags ACK,PSH PSH -j DROP -m comment --comment "Drop: ACK,PSH,PSH"
sudo iptables -A INPUT -p tcp --tcp-flags ACK,URG URG -j DROP -m comment --comment "Drop: ACK URG URG" 
sudo iptables -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP -m comment --comment "Drop: SYN,FIN,SYN,FIN"
sudo iptables -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j DROP -m comment --comment "Drop: SYN,RST,SYN,RST"
sudo iptables -A INPUT -p tcp --tcp-flags FIN,RST FIN,RST -j DROP -m comment --comment "Drop: FIN,RST,FIN,RST"
sudo iptables -A INPUT -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP -m comment --comment "Drop: FIN,PSH,URG"

# F: Allow Specific Input Rules #

# Loopback: (Drop False Packets, Allow Loopback = Host Only) #
sudo iptables -A INPUT --in-interface !lo --source 127.0.0.0/8 -j DROP -m comment --comment "Drop: Outbound Loopback"
sudo iptables -A INPUT --in-interface lo -j ACCEPT -m comment --comment "Accept: Local Loopback"

# Ethernet & WLAN - 
# * Allow Pre-Established Output States inbound #
# * Block IMCP Ping < 1 Per Second #
sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT -m comment --comment "Accept: Outbound Traffic with Related Input: Ex: Chrome, DHCP"
sudo iptables -A INPUT -p icmp -m icmp --icmp-type echo-request -m limit --limit 1/second -j ACCEPT -m comment --comment "Accept: Ping Request Only, Rate: 1 per Second"

# Catch-ALL : Send Reject #
sudo iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable -m comment --comment "Reject: Inbound: All UDP"
sudo iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset -m comment --comment "Reject: Inboud: All TCP"
sudo iptables -A INPUT -j REJECT --reject-with icmp-proto-unreachable -m comment --comment "Reject: Inboud: All UnMarked Traffic"

sudo iptables -A FORWARD -p udp -j REJECT --reject-with icmp-port-unreachable -m comment --comment "Reject: Forward: All UDP"
sudo iptables -A FORWARD -p tcp -j REJECT --reject-with tcp-reset -m comment --comment "Reject: Forward: All TCP"
sudo iptables -A FORWARD -j REJECT --reject-with icmp-proto-unreachable -m comment --comment "Reject: Forward: All UnMarked Traffic"

# G: Save Firewall on Reboot #
sudo bash -c "iptables-save > /etc/iptables/rules.v4"
sudo bash -c "ip6tables-save > /etc/iptables/rules.v6"
