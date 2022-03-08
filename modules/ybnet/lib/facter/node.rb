Facter.add(:node) do
    setcode do
       %x{grep -q node_type /etc/nodeinfo.ini 2>/dev/null && { grep "node_type" /etc/nodeinfo.ini |awk -F: '{print $NF}'  ;} ||echo 10}.chomp 
    end
end
