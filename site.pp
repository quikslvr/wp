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
	exec { "reload_nginx":
    		command => "/etc/init.d/nginx reload",
    		#path    => "/usr/local/bin/:/bin/",
    		# path    => [ "/usr/local/bin/", "/bin/" ],  # alternative syntax
	}
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
    file { "/etc/php5/fpm/pool.d/www.conf":
	source => "puppet://puppet.server/files/cfg/php-fpm.conf",
	mode => 644,
	require => Package["php5-fpm"],
	exec { "reload_php-fpm":
    		command => "/etc/init.d/php-fpm reload",
    		#path    => "/usr/local/bin/:/bin/",
    		# path    => [ "/usr/local/bin/", "/bin/" ],  # alternative syntax
	}
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
