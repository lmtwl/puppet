Facter.add(:proxy_status) do
    setcode do
        %x{ pgrep -l httpproxy >/dev/null 2>&1 && echo 0 || echo 1 }.chomp
    end
end