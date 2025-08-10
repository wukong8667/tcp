cat > tcp_agent_opt.sh <<'EOF'
#!/bin/bash
# 隧道/跳板专用 TCP 栈优化+ulimit文件数设置（无进程重启）

# 1. TCP内核参数优化
cat > /etc/sysctl.d/99-proxy-opt.conf <<EOL
fs.file-max = 1048576
net.core.somaxconn = 65535
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 65536
net.core.optmem_max = 32768

net.ipv4.tcp_max_syn_backlog = 65536
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_fin_timeout = 10
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_tw_buckets = 2000000
net.ipv4.ip_local_port_range = 1024 65535

net.ipv4.tcp_mtu_probing = 1

net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864

net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOL

sysctl --system

# 2. 文件句柄限制优化
grep -q "soft nofile" /etc/security/limits.conf || echo '* soft nofile 1048576' >> /etc/security/limits.conf
grep -q "hard nofile" /etc/security/limits.conf || echo '* hard nofile 1048576' >> /etc/security/limits.conf
ulimit -n 1048576

echo -e "\033[32m[TCP优化] 内核参数和ulimit文件数已生效，无需重启服务进程。后续新进程将自动获得优化效果。\033[0m"
EOF

chmod +x tcp_agent_opt.sh
bash tcp_agent_opt.sh
