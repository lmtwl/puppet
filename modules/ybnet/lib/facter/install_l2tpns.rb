Facter.add(:install_l2tpns) do
    setcode do
       %x{dpkg -l | grep ysnet-l2tpns > /dev/null 2>&1 ;echo $? }.chomp 
    end
end
