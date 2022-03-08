Facter.add(:dnsmasq_installed) do
    setcode do
       %x{dpkg -l | grep dnsmasq > /dev/null 2>&1 ;echo $? }.chomp 
    end
end
