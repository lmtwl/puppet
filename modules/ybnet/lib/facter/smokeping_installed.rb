Facter.add(:smokeping_installed) do
    setcode do
       %x{dpkg -l smokeping > /dev/null 2>&1 ;echo $? }.chomp 
    end
end
