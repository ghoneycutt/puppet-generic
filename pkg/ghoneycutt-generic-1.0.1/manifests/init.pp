# Class: generic
#
# This module is applied to *ALL* nodes
#
# Requires:
#   class $operatingsystem
#   class backup
#   class certs
#   class dnsclient
#   class facter
#   class hosts
#   class logrotate
#   class logwatch
#   class postfix
#   class puppet
#   class rsync
#   class snmp
#   class ssh
#   class sudo
#   class syslog_ng::client
#   class utils
#   class vim
#   $lsbProvider be set in site manifest
#
class generic {

    include $operatingsystem
    include backup
    include certs
    include dnsclient
    include facter
    include hosts
    include logrotate
    include logwatch
    include postfix
    include puppet
    include rsync
    include snmp
    include ssh
    include sudo
    include syslog_ng::client
    include utils
    include vim

    file {
        # our hierarchical namespace as registered with LANANA
        "/opt/$lsbProvider":
            mode   => 755,
            ensure => directory;
        # directory structure that we use everywhere
        "/data":
            mode   => 755,
            ensure => directory;
    } # file

    # Definition: mkuser
    #
    # mkuser creates a user/group that can be realized in the module that employs it
    #
    # Parameters:
    #   $uid        - UID of user
    #   $gid        - GID of user, defaults to UID
    #   $group      - group name of user, defaults to username
    #   $shell      - user's shell, defaults to "/bin/bash"
    #   $home       - home directory, defaults to /home/<username>
    #   $ensure     - present by default
    #   $managehome - true by default
    #   $dotssh     - creates ~/.ssh by default
    #   $comment    - comment field for passwdany additional groups the user should be associated with
    #   $groups     - any additional groups the user should be associated with
    #   $password   - defaults to "!!"
    #   $symlink    - use a symlink for the home directory
    #   $mode       - mode of home directory, defaults to 700
    #
    # Actions: creates a user/group
    #
    # Requires:
    #   $uid
    #
    # Sample Usage:
    #   "apachehup":
    #       uid        => "32001",
    #       gid        => "32001",
    #       home       => "/home/apachehup",
    #       managehome => "true",
    #       comment    => "Apache Restart User",
    #       dotssh     => "true";
    #
    define mkuser ($uid, $gid = undef, $group = undef, $shell = "/bin/bash", $home = undef, $ensure = "present", $managehome = true, $dotssh = "ensure", $comment = "created via puppet", $groups = undef, $password = "!!", $symlink = undef, $mode = undef) {

        # if gid is unspecified, match with uid
        if $gid {
            $mygid = $gid
        } else {
            $mygid = $uid
        }

        # if home is unspecified, use /home/<username>
        if $home {
            $myhome = $home
        } else {
            $myhome = "/home/$name"
        }

        # if group is unspecified, use the username
        if $group {
            $mygroup = $group
        } else {
            $mygroup = $name
        }

        # create user
        user { "$name":
            uid        => "$uid",
            gid        => "$mygid",
            shell      => "$shell",
            groups     => "$groups",
            password   => "$password",
            managehome => "$managehome",
            home       => "$myhome",
            ensure     => "$ensure",
            comment    => "$comment",
            require    => Group["$name"],
        } # user

        group { "$name":
            gid    => "$mygid",
            name   => "$mygroup",
            ensure => "$ensure",
        } # group

        # if link is passed a symlink will be used for ensure => , else we will make it a directory
        if $symlink {
            $myEnsure = $symlink
        } else {
            $myEnsure = "directory"
        }

        # if mode is unspecified, use 700
        if $mode {
            $myMode = $mode
        } else {
            $myMode = "700"
        }

        # create home dir
        file { "$myhome":
            ensure  => $myEnsure,
            mode    => $myMode,
            owner   => $name,
            group   => $name,
            require => User["$name"],
        } # file

        # create ~/.ssh
        case $dotssh {
            "ensure","true": {
                file { "$myhome/.ssh":
                    ensure  => directory,
                    mode    => "700",
                    owner   => $name,
                    group   => $name,
                    require => User["$name"],
                } # file
            } # 'ensure' or 'true'
        } # case
    } # define mkuser

    define mkgroup ($gid) {
        group { "$name":
            ensure => present,
            gid    => "$gid",
            name   => "$name",   
        } # group
    } # define mkgroup

    # this is all listed here and realized within the module with 'realize Generic::Mkuser[username]'
    # it is here and not in the modules, so that we have one place to list all the uid/gid's
    # to avoid using the same numbers
    #
    # please keep sorted by UID
    @mkuser {
        #"gh":
        #    uid        => "32000",
        #    gid        => "32000",
        #    home       => "/home/gh",
        #    comment    => "garrett honeycutt";
        "apachehup":
            uid        => "32001",
            gid        => "32001",
            home       => "/home/apachehup",
            managehome => "true",
            comment    => "Apache Restart User",
            dotssh     => "true";
        "memcached":
            uid        => "32002",
            gid        => "32002",
            dotssh     => "false";
        "rt":
            uid        => "32003",
            gid        => "32003",
            home       => "/home/rt",
            managehome => "false",
            comment    => "RT User",
            dotssh     => "false";
        "puppetreposvn":
            uid        => "32005",
            gid        => "32005";
        "puppetreposvn-master":
            uid        => "32006",
            gid        => "32006";
        "dnsreposvn":
            uid        => "32007",
            groups     => [ "named" ];
    } # @mkuser

    # this is all listed here and realized within the module with 'realize Generic::Mkgroup[groupname]'
    # it is here and not in the modules, so that we have one place to list all the uid/gid's
    # to avoid using the same numbers
    #
    # please keep sorted by GID
    @mkgroup {
        "systems":
            gid => "30000",
        #"marketing":
        #    gid => "30001";
        #"dev":
        #    gid => "30002";
        #"finance":
        #    gid => "30003";
        #"hr":
        #    gid => "30004";
        #"cs":
        #    gid => "30005";
        #"qa":
        #    gid => "30006";
        #"bizdev":
        #    gid => "30007";
        #full time employees
        #"fte":
        #    gid => "30008";
        #"employee":
        #    gid => "30009";
    } # @mkgroup

    realize Mkgroup[systems]
} # class generic
