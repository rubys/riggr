status = ARGV.shift
url = ARGV.shift
message = ARGV.shift

require 'config/environment.rb'
require 'xmpp4r'

xnotify = YAML.load(open('/home/rubys/.xnotify.yml'))
xnotify.each {|key,server| server['subs'] = []}

toc = open(SOURCE).read.split('<h2>')[1]
fail = toc.index('color:red')

RegistryAwdwr.all.each do |record|
  next if record.level == 'none'
  next if record.level == 'fail' and status != 'fail'

  dest = record.xmpp[/@([\w\.]+)/,1]
  dest = 'DEFAULT' unless xnotify.has_key?(dest)
  xnotify[dest]['subs'] << record
end

xnotify.each do |key,server|
  next if server['subs'].empty?

  jclient = Jabber::Client.new(Jabber::JID.new(server['user']))
  jclient.connect.auth(server['password'])
  server['subs'].each do |sub|
    jmessage = Jabber::Message.new(sub['xmpp'], message)

    html = jmessage.add_element('html')
    html.add_namespace('http://jabber.org/protocol/xhtml-im')
    body = html.add_element('body')
    body.add_namespace('http://www.w3.org/1999/xhtml')
    body << REXML::Document.new("<a href='#{url}'>#{message}</a>").root
    jclient.send jmessage
  end
  jclient.close
end
