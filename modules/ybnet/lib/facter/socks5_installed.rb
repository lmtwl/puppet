Facter.add(:socks5_installed) do
    setcode do
       %x{dpkg -l | grep ysnet-socks5 > /dev/null 2>&1 ;echo $? }.chomp 
    end
end
