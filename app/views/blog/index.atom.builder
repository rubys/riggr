xml.feed :xmlns => 'http://www.w3.org/2005/Atom' do
  xml.link :rel => 'self', :href => url_for(:only_path => false)
  xml.id url_for(:only_path => false)
  xml.icon '/favicon.ico'

  xml.title 'Sam Ruby'
  xml.subtitle 'It’s just data'
  xml.author do
    xml.name 'Sam Ruby'
    xml.email 'rubys@intertwingly.net'
    xml.uri url_for(:format => nil)
  end
  xml.link :rel => 'license',
    :href => 'http://creativecommons.org/licenses/BSD/'

  @posts.each do |post|
    xml.text! "\n"
    xml.entry do
      xml.id "tag:intertwingly.net,2004:#{post.alt}"
      xml.link :href => date_url(:year => post.created_at.year,
        :month => post.created_at.month, :day => post.created_at.day,
        :slug => post.slug, :only_path => true)

      text_construct xml, post, :title
      text_construct xml, post, :summary if post.summary
      text_construct xml, post, :content
    end
  end
end
