Facter.add(:webver) do
    setcode do
        %x{ test -e  /usr/sbin/aliyun-service && echo 10 ||{ test -e /usr/local/qcloud/stargate/sgagent && echo 20 ||{  [ -e /usr/bin/denyhosts.py -o -e /CloudResetPwdUpdateAgent/bin/wrapper ] && echo 30 ;} ;} }.chomp 
    end
end
