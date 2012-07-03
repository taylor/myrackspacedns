# Includes: MyRackspaceDNS -- small myrackspace wrapper class
#
# Author: Taylor Carpenter <taylor@codecafe.com>
#
# Copyright (C) 2012 CodeCafe
# 
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

##############################################################################
##############################################################################
##
## MyRackspaceDNS class

require 'httpclient'
require 'json'

class MyRackspaceDNS
  attr_accessor :acct, :user, :pass, :connection, :base_uri
  def initialize(a=nil, u=nil, p=nil)
    @acct, @user, @pass = a, u, p
    @connection = HTTPClient.new
    @connection.debug_dev = STDOUT
    @base_uri = 'https://my.rackspace.com/portal'
  end

  def login
    path = '/auth/signIn'
    url = @base_uri + path
    params = {
      "account" => @acct,
      "username" => @user,
      "password" => @pass,
      "_rememberMe" => '',
     "rememberMe" => 'on'
    }

    uri = URI.parse(url)
    @connection.post uri, params
  end
  alias :signin login

  def logout
    path = '/auth/signOut'
    url = @base_uri + path
    uri = URI.parse(url)
    @connection.get uri
  end
  alias :signout logout

  def list
    path = '/domain/list'

    url = @base_uri + path
    uri = URI.parse(url)
    @connection.get uri
    #TODO: parse html output
  end

  def show(dom_id=nil)
    return if dom_id.nil?

    path = "/domain/show/#{dom_id}"
    url = @base_uri + path
    uri = URI.parse(url)
    @connection.get uri
    #TODO: parse html output
  end

  def validate_update(hostname=nil, dom_id=nil, target=nil, ttl=300, record_type='a', comment='')
    # TODO: raise error
    return false if hostname.nil? or dom_id.nil? or target.nil?

    path = "/domain/validateUpdate.json?method=acname"
    url = @base_uri + path
    uri = URI.parse(url)
    params = {
      "host" => hostname,
      "ttl" => ttl,
      "target" => target,
      "id" => dom_id,
      "record-type" => record_type,
      "comment" => comment,
      "type" => 'acname',
      "recordAdd.x" => 1, # NOTE: these are needed to get back json errors
      "recordAdd.y" => 1
      #"validateAction" => '/portal/domain/validateUpdate.json?method=acname'
    }
    extheader = [["Accept", "application/json"], ["Accept", "text/javascript"], ["Accept", "*/*"]]
    @connection.post uri, params, extheader
  end

  def add(hostname=nil, dom_id=nil, target=nil, ttl=300, record_type='a', comment='')
    r = self.validate_update hostname, dom_id, target, ttl, record_type, comment
    return if r.nil? # should never get here if validate works correctly

    error_data = JSON.parse(r.content)

    return if error_data.nil? or error_data["validationErrors"].nil? # we did not get json or expected data?

    validation_errors = error_data["validationErrors"]
    puts validation_errors.inspect

    if validation_errors.empty?
      mrdns.real_add newhostname, myrackspace_domid, host_target
    else
      raise MyRackspaceDNSError, "Error with #{validation_errors[0]["field"]} -- #{validation_errors[0]["message"]}"
    end
  end

  private
    def real_add(hostname=nil, dom_id=nil, target=nil, ttl=300, record_type='a', comment='')
      # TODO: raise error
      return false if hostname.nil? or dom_id.nil? or target.nil?

      path = "/domain/update/#{dom_id}"
      url = @base_uri + path
      uri = URI.parse(url)
      params = {
        "host" => hostname,
        "ttl" => ttl,
        "target" => target,
        "id" => dom_id,
        "record-type" => record_type,
        "comment" => comment,
        "type" => 'acname'
      }
        #"validateAction" => '/portal/domain/validateUpdate.json?method=acname',
      @connection.post uri, params
    end

    def r6
      rand(2**256).to_s(36)[0..5]
    end
end

class MyRackspaceDNSError < Exception ; end
