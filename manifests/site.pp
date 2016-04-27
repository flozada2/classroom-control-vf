node default {
# This is where you can declare classes for all nodes.
# Example:
# class { 'my_class': }
if $::virtual != 'physical' {
$vmname = capitalize($::virtual)
notify { "This is a ${vmname} virtual machine.": }
}
}
