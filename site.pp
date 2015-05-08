class passwd {
    file { "/etc/passwd":
	owner => root,
	group => root,
	mode => 644,
    }
}

class nginx {
    package { "nginx":
	ensure => latest,
    }
    service { "nginx":
	ensure => running,
	require => Package["nginx"],
    }
    file { "/etc/nginx/sites-available/wp.example.net":
	source => "puppet://puppet.server/files/cfg/wp.example.net",
	mode => 644,
	require => Package["nginx"],
    }
}

class php-fpm {
    package { "php5-fpm":
	ensure => latest,
    }
    package { "php5-curl":
	ensure => latest,
    }
    package { "php5-mysql":
	ensure => latest,
    }

    service { "php5-fpm":
    	ensure => running,
    	require => Package["php5-fpm"],
    }
}

class mysql {
    package { "mysql-server":
	ensure => latest,
    }
    package { "mysql-client":
	ensure => latest,
    }
    service { "mysql":
	ensure => running,
	require => Package["mysql-server"],
    }
}

node default {
    include passwd
    include nginx
    include php-fpm
    include mysql
}
