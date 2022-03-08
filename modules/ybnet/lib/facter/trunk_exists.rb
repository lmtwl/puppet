Facter.add(:trunk_exists) do
    setcode do
       %x{ip link show trunk >/dev/null 2>&1 ; echo $?}.chomp 
    end
end
