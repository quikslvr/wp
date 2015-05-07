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
node default {
    include passwd
    include nginx
}
