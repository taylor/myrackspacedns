#!/usr/bin/env ruby

script_path = Dir.chdir(File.expand_path(File.dirname(__FILE__))) { Dir.pwd }
lib_path = Dir.chdir(script_path + '/../lib') { Dir.pwd }
$:.unshift lib_path

require 'myrackdns'

#require 'rufus/mnemo'
require 'random-word'

host_target = ARGV[0]
if host_target.nil?
  puts "usage: $0 <target_ip>"
  exit 0
end

myrackspace_acct=ENV['MYRACKSPACE_ACCT']
myrackspace_user=ENV['MYRACKSPACE_USER']
myrackspace_pass=ENV['MYRACKSPACE_PASS']
myrackspace_domid=ENV['MYRACKSPACE_DOMAIN_ID']

if myrackspace_pass.nil? or myrackspace_user.nil? or myrackspace_acct.nil?
  puts "Must have MYRACKSPACE variables set"
  exit 1
end

mrdns = MyRackspaceDNS.new(myrackspace_acct, myrackspace_user, myrackspace_pass)
mrdns.login

hnprefix = "cloud"
rword="#{RandomWord.adjs.next}-#{RandomWord.nouns.next}"
rdigit=rand(99999)
newhostname="#{hnprefix}-#{rword}-#{rdigit}"

mrdns.add newhostname, myrackspace_domid, host_target
mrdns.signout

