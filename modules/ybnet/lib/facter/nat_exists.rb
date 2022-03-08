Facter.add(:nat_exists) do
    setcode do
       %x{ip link show nat >/dev/null 2>&1 ; echo $?}.chomp 
    end
end
