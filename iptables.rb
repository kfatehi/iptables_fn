# my target system is ubuntu 12.04
# H1 is hypervisor (localhost to this script)
# H2 is a VM running a service on port P2
# H1 needs to expose and forward P1 to H2:P2

# this program must run with root priveleges
require './shell_helper'

module Iptables
  include ShellHelper

  def ensure_kernel_forwarding
    unless runcmd("sysctl net.ipv4.ip_forward") =~ /1/
      runcmd("sysctl net.ipv4.ip_forward=1")
    end
  end

  def forward_packets port1, host2, port2, protocol="tcp"
    runcmd "iptables -t nat -A PREROUTING -p #{protocol} --dport #{port1} -j DNAT --to #{host2}:#{port2}"
    runcmd "iptables -A FORWARD -d #{host2} -p #{protocol} --dport #{port2} -j ACCEPT"
    ensure_kernel_forwarding
  end

  def unforward_packets port1, host2, port2, protocol="tcp"
    runcmd "iptables -t nat -D PREROUTING -p #{protocol} --dport #{port1} -j DNAT --to #{host2}:#{port2}"
    runcmd "iptables -D FORWARD -d #{host2} -p #{protocol} --dport #{port2} -j ACCEPT"
  end

  def accept_packets port, protocol="tcp"
    runcmd "iptables -I INPUT -p #{protocol} --dport #{port} -j ACCEPT"
  end

  def unaccept_packets port, protocol="tcp"
    runcmd "iptables -D INPUT -p #{protocol} --dport #{port} -j ACCEPT"
  end

  def apply
    runcmd "service iptables save"
    runcmd "service iptables restart"
  end
end
