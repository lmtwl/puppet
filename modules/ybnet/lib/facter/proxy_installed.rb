Facter.add(:proxy_installed) do
    setcode do
       %x{ dpkg -l ysnet-proxy >/dev/null 2>&1 && echo 10 || echo 0 }.chomp 
    end
end
