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
}
lass php-fpm {
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

node default {
    include passwd
    include nginx
}
