class ybnet::ssh {
  user {
    "root":
      ensure   => present,
      shell =>"/bin/bash",
      home  => "/root",
      managehome => true,
      password => '$6$RYqOzXwPXI4fAIxq$dZtJpNjtaFNPYjsvWIv3orBiiJhs9EtxfbCK8.dQqJFa7zwfWE9LgGX/Yb9bx38LPvT8aUqUtlLEicOFPho44.';
  }
  file { '/etc/hosts.allow':
    mode => "0644",
    source => "puppet:///modules/${module_name}/ssh/hosts.allow";
    '/etc/hosts.deny':
      mode => "0644",
      source => "puppet:///modules/${module_name}/ssh/hosts.deny";
  }
  ssh_authorized_key {
    "root":
      user => root,
      type => "ssh-rsa",
      key => "AAAAB3NzaC1yc2EAAAADAQABAAABAQDlZJRLOy+1o7s2UvSqNJJM4BDJ8kHpcOFN4+ipi5jPNXkO3LXlOQXbDLCk9E+wk+IYVS9M5TvP+qYksDvFFhHiNTxhJhcn1i7620IocdDy3b63ejC1NisCyOmmw+cTY8j+kxQVjOm8/KRvMJ7bGWARwnK9GRjyVs40D02tsxwAUqX/h6FQ45ahwuIjshspL2mGDsfSadYt5wgKneEEOYHcN4vkLf/6Kc7vEOa67MpeeFJOUtqbOewTM7i8H3kLPDb/zJdp6pyRIZpkfgbr7+e26oO/OFJ82hvyk6d/Nqf4EaYNo2JjzQBV8qdMxb4cat/CjUQdYDg9HyrazBR3rokP";
  }
  augeas { "set sshd_config":
    context => "/files/etc/ssh/sshd_config",
    changes => [
      "set PermitRootLogin without-password",
      "set Port 22",
      "set X11Forwarding no",
      "set PasswordAuthentication yes",
      ]
  }

  service {
    "ssh":
      subscribe => Augeas["set sshd_config"],
      ensure => running;
  }
}
