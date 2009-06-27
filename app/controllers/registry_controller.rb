require 'xmpp4r/client'

class RegistryController < ApplicationController
  layout 'blog'

  def awdwr
    servers = YAML.load(open("#{ENV['HOME']}/.xnotify.yml"))
    @servers = servers.reject {|key,value| value['class']=='private'}
    # @servers.each_value {|value| value.delete('password')}

    @record = session[:openid]

    if params[:email] != nil or @record == nil
      openid = params[:openid_url] || cookies[:openid]
      @record = RegistryAwdwr.find_by_openid(openid) || RegistryAwdwr.new

      @record.openid ||= openid
      @record.name = params[:name] || @record.name
      @record.xmpp = params[:email] || @record.xmpp
      @record.level = params[:level] || @record.level || 'fail'

      session[:openid] = @record
    end

    if request.post? and @record and not @record.xmpp.empty?
      session[:openid_mode] = 'test' if params[:test]
      authenticate_with_open_id do |result, identity_url|
        if result.successful?
          if session[:openid_mode] == 'test'
            dest = @record.xmpp[/@([\w\.]+)/,1]
            server = servers[dest] || servers['DEFAULT']
            
            plain_text = "This is a plaintext message.  " +
              "If you see this, your client does NOT support XHTML-IM."
            xhtml_im = 'http://www.xmpp.org/extensions/xep-0071.html'
            xhtml = "This is an <a href='#{xhtml_im}'>XHTML-IM</a> message. " +
              "If you see this, your client <b>does</b> support XHTML-IM."

            jclient = Jabber::Client.new(Jabber::JID.new(server['user']))
            jclient.connect.auth(server['password'])
            jclient.send(Jabber::Presence.new.set_type(:probe))
            jclient.send(Jabber::Presence.new.set_type(:subscribe))
            jmessage = Jabber::Message.new(@record.xmpp, plain_text)

            html = jmessage.add_element('html')
            html.add_namespace('http://jabber.org/protocol/xhtml-im')
            body = html.add_element('body')
            body.add_namespace('http://www.w3.org/1999/xhtml')
            REXML::Document.new("<p>#{xhtml}</p>").root.children.each do |child|
              body << child
            end
            jclient.send jmessage
            jclient.close
          else
            @record.save!
            cookies[:openid] = {:value => @record.openid,
                                :expires => 1.year.from_now}
          end
        else
          flash[:notice] = result.message || "login as #{record.xmpp} failed"
        end
        session[:openid_mode] = nil
        session[:openid] = nil
      end
    end
  end
end
