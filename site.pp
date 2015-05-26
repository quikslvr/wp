
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
    package { 
    	"php5-gd":
	ensure => latest,
    }
    package { 
    	"php5-memcache":
	ensure => latest,
    }
    package { 
    	"php5-mysqlnd":
	ensure => latest,
    }
    package { 
    	"php-pear":
	ensure => latest,
    }
    package {
    	"build-essential":
	ensure => latest,
    }
    package { 
    	"php5-dev":
	ensure => latest,
    } 
    package {  
    	"gearman-job-server":
	ensure => latest,
    }
    package {  
    	"libgearman-dev":
	ensure => latest,
    }
    package {
    	"libyaml-dev":
	ensure => latest,
    }
    service { 
    	"php5-fpm":
    	ensure => running,
    	require => Package["php5-fpm"],
    	restart => "/etc/init.d/php5-fpm reload",
    }
    exec { "yaml":
    	command => "/usr/bin/pecl install yaml",
    	creates => "/usr/lib/php5/20100525/20-yaml.so"
    } 
    exec { "gearman":
    	command => "/usr/bin/pecl install gearman",
    	#creates => "/usr/lib/php5/20100525/opcache.so"
    } 
    exec { "ZendOpcache":
    	command => "/usr/bin/pecl install ZendOpcache",
    	creates => "/usr/lib/php5/20100525/opcache.so"
    } 
    #exec { "sphinx":
    	#command => "/usr/bin/pecl install sphinx",
    	#creates => "/usr/lib/php5/20100525/opcache.so"
    #} 
    
    file { 
    	"/etc/php5/conf.d/20-yaml.so":
	source => "puppet://puppet.server/files/cfg/20-yaml.so",
	mode => 644,
	require => Package["php5-fpm"],
	notify  => Service["php5-fpm"],
    }
    file { 
    	"/etc/php5/conf.d/gearman.ini":
	source => "puppet://puppet.server/files/cfg/gearman.ini",
	mode => 644,
	require => Package["php5-fpm"],
	notify  => Service["php5-fpm"],
    }
    file { 
    	"/etc/php5/conf.d/20-opcache.ini":
	source => "puppet://puppet.server/files/cfg/20-opcache.ini",
	mode => 644,
	require => Package["php5-fpm"],
	notify  => Service["php5-fpm"],
    }
    
    file { 
    	"/etc/php5/fpm/pool.d/www.conf":
	source => "puppet://puppet.server/files/cfg/php-fpm.conf",
	mode => 644,
	require => Package["php5-fpm"],
	notify  => Service["php5-fpm"],
    }
}

class mysql_wp {
    package { 
    	"mysql-server":
	ensure => latest,
    }
    package { 
    	"mysql-client":
    	ensure => latest,
    }

    class wordpress_db {
    	class { 
    		'::mysql::server':
    		root_password    => 'wordpress',
    		override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  	}
	mysql::db { 
		'wordpress':
  		user => 'wordpress',
  		password => 'wordpress',
  		host => 'localhost',
  		grant => ['ALL'],
	}
    }
    service { 
    	"mysql":
	ensure => running,
	require => Package["mysql-server"],
    }
}

node default {
    include nginx
    include php-fpm
    include mysql_wp
}
