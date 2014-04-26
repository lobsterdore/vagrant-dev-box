
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

file { "/etc/init.d/solr":
	ensure => 'file',
	source => "puppet:///files/solr/solr",
	mode => 744,
	#require => File["/usr/local/solr"]
}

service { 'solr':
	ensure => running,
	enable => true,
	require => File["/etc/init.d/solr"]
}

class { '::mysql::server': }

package { "nginx":
	ensure => "present"
}

service { 'nginx':
	ensure => running,
	require => Package["nginx"]
}
