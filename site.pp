
class nginx {
    package { 
    	"nginx":
	ensure => latest,
    }
    service { 
    	"nginx":
	ensure => running,
	require => Package["nginx"],
	restart => "/etc/init.d/nginx reload",
    }
 
    file { 
    	"/etc/nginx/sites-available/default":
	source => "puppet://puppet.server/files/cfg/wp.example.net",
	mode => 644,
	require => Package["nginx"],
	notify  => Service["nginx"],
    }
    
    file {
    	"/var/www" :
    	ensure => directory,
    	owner => "www-data",
	group => "www-data",
	mode => "0775",
    }
    
    package { 
 	'git':
 	ensure => installed,
    }
    
    vcsrepo { 
    	"/var/www/wp/":
        ensure   => latest,
        owner    => www-data,
        group    => www-data,
        provider => git,
        require  => [ Package["git"] ],
        source   => "https://bitbucket.org/quikslvr/wp_files.git",
        revision => 'master',
    } 
}

class php-fpm {
    package { 
    	"php5-fpm":
	ensure => latest,
    }
    package { 
    	"php5-curl":
	ensure => latest,
    }
    package { 
    	"php5-mysql":
	ensure => latest,
    }
    service { 
    	"php5-fpm":
    	ensure => running,
    	require => Package["php5-fpm"],
    	restart => "/etc/init.d/php5-fpm reload",
    }
    file { 
    	"/etc/php5/fpm/pool.d/www.conf":
	source => "puppet://puppet.server/files/cfg/php-fpm.conf",
	mode => 644,
	require => Package["php5-fpm"],
	notify  => Service["php5-fpm"],
    }
}

class mysql {
    package { 
    	"mysql-server":
	ensure => latest,
    }
    package { 
    	"mysql-client":
    	ensure => latest,
    }

    service { 
    	"mysql":
	ensure => running,
	#require => Package["mysql-server"],
    }
}
class wordpress_db {
	class { 
		'::mysql::server':
    		root_password    => 'strongpassword',
    		override_options => { 'mysqld' => { 'max_connections' => '1024' } }
    	}
}
node default {
    include nginx
    include php-fpm
    include mysql
    include wordpress_db
}
