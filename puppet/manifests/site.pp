
exec { "apt-update":
	command => "/usr/bin/apt-get update",
	refreshonly => true
}

package { [
		"openjdk-6-jdk",
	]:
	ensure => "purged"
}

package { [
		"vim",
		"curl",
		"build-essential",
		"python-mysqldb",
		"openjdk-7-jre",
		"daemon",
		"screen",
		"git"
	]:
	ensure => "present",
	require  => Exec['apt-update']
}

file { "/etc/environment":
	content => inline_template("
		PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games
		export PYTHONPATH=$PYTHONPATH:/shared/apps/python
		export SPANGLE_CORE_CONFIG=/home/sites/config/spanglecore.cfg
	")
}

class { 'python':
	version => 'system',
	dev  => true,
	pip => true
}

python::requirements { '/shared/apps/python/spanglecms/requirements.txt': }

python::requirements { '/shared/apps/python/spanglecore/requirements.txt': }

# horrible hack way of doing solr for now
#file { "/usr/local/solr":
#	source => "puppet:///files/solr/src",
#	ensure  => directory,
#	recurse => true,
#}

#file { "/etc/init.d/solr":
#	ensure => 'file',
#	source => "puppet:///files/solr/solr",
#	mode => 744,
#	require => File["/usr/local/solr"]
#}

#service { 'solr':
#	ensure => running,
#	enable => true,
#	require => File["/etc/init.d/solr"]
#}

class { '::mysql::server':
	override_options => { 'mysqld' => { 'bind_address' => '0.0.0.0' } },
}

package { "nginx":
	ensure => "present"
}

file { "/etc/nginx/nginx.conf":
	ensure => 'file',
	source => "puppet:///files/etc/nginx/nginx.conf",
	require => Package["nginx"],
	owner => 'root',
	group => 'root',
	mode => 0644
}

service { 'nginx':
	ensure => running,
	require => File["/etc/nginx/nginx.conf"]
}

package { [
                        'php5',
                        'php5-cli',
                        'php-apc',
                        'php5-curl',
                        'php5-dev',
                        'php5-gd',
                        'php5-mcrypt',
                        'php5-memcache',
                        'php5-mysql',
                        'php5-pspell',
                        'php5-tidy',
                        'php5-json'
	]:
	ensure => "present",
	require => Package["nginx"]
}

package { "php5-fpm":
	ensure => "present"
}

file { "/etc/php5/fpm/pool.d/www.conf":
	ensure => 'file',
	source => "puppet:///files/etc/php5/fpm/pool.d/www.conf",
	require => Package["php5-fpm"],
	owner => 'root',
	group => 'root',
	mode => 0644
}

service { 'php5-fpm':
	ensure => running,
	require => File["/etc/php5/fpm/pool.d/www.conf"]
}

file { "/var/log/gunicorn":
	ensure  => directory
}

file { "/var/run/gunicorn":
	ensure  => directory
}

class { 'docker': }

package { [
		'apache2',
		'libapache2-mod-php5'
	]:
	ensure => "present"
}

service { 'apache2':
	ensure => running,
	require => Package["apache2"]
}

class { 'ruby':
	gems_version  => 'latest'
}

class { 'nodejs':
  version => 'stable',
}

package { 'grunt-cli':
	ensure   => present,
	provider => 'npm',
}

