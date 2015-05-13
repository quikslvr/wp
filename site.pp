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
    file { "/etc/nginx/sites-available/default":
	source => "puppet://puppet.server/files/cfg/wp.example.net",
	mode => 644,
	require => Package["nginx"],
    }
    #exec { "delete_default":
    #		command => "/bin/rm /etc/nginx/sites-enabled/default",
    #		onlyif => "/bin/cat /etc/nginx/sites-enabled/default",
    #}
    #exec { "make_symlink":
    #		command => "/bin/ln -s /etc/nginx/sites-available/wp.example.net /etc/nginx/sites-enabled/wp.example.net",
    #		onlyif => [ 
    #            	"/bin/ln -s /etc/nginx/sites-available/wp.example.net /etc/nginx/sites-enabled/wp.example.net",
    #            	"/bin/cat /etc/nginx/sites-enabled/wp.example.net",
    #    	],
    #		require => File["/etc/nginx/sites-available/wp.example.net"],
    #}

    file {
    	"/var/www" :
    	ensure => directory,
    	owner => "www-data",
	group => "www-data",
	mode => "0775",
    }
    #file {
    #	"/var/www/wp" :
    #	ensure => directory,
    #	owner => "www-data",
#	group => "www-data",
#	mode => "0775",
 #   }
    #file {
#	"/var/www/wp" :
#	ensure => directory,
#	source => "puppet://puppet.server/files/wp_files/wordpress",
#	recurse => true,
#	purge => true,
#	backup => false,
#	owner => "www-data",
#	group => "www-data",
#	mode => "0775",
 #   }
 package { 'git':
        ensure => installed,
    }
    
    vcsrepo { "/var/www/wp/":
        ensure   => latest,
        owner    => www-data,
        group    => www-data,
        provider => git,
        require  => [ Package["git"] ],
        source   => "https://bitbucket.org/quikslvr/wp_files.git",
        revision => 'master',
        user => 'quikslvr',
    } 
    
    exec { "reload_nginx":
    		command => "/etc/init.d/nginx reload",
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
    file { "/etc/php5/fpm/pool.d/www.conf":
	source => "puppet://puppet.server/files/cfg/php-fpm.conf",
	mode => 644,
	require => Package["php5-fpm"],
    }
    exec { "reload_php-fpm":
    		command => "/etc/init.d/php5-fpm reload",
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

#class { 'mysql::server': config_hash => { 'root_password' => 'wordpress' } }
#class { 'mysql::db': { 'mydb':
#user => 'wordpress',
#password => 'password',
#host => 'localhost',
#grant => ['all'] } }

node default {
    include passwd
    include nginx
    include php-fpm
    include mysql
}
