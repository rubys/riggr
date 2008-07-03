class Comment < ActiveRecord::Base
  attr_accessor :title, :content, :sig
  belongs_to :post

  def self.import! filename
    comment = Comment.new
    comment.created_at = File.stat(filename).mtime.utc
    name = File.basename(filename).gsub(/\.cmt/,'')
    comment.slug = name
    if name =~ /^(\d+)-/
      comment.post = Post.find_by_alt($1.to_i)
    else
      comment.post = Post.find_by_slug(name.gsub(/-.*/,'').gsub('_','-'))
    end
    dest = "#{Post::FILESTORE}/#{comment.filename}"
    FileUtils.mkdir_p File.dirname(dest)
    FileUtils.cp filename, dest, :preserve => true
    comment.save!
  end

  def filename
    self.created_at.strftime('%Y/%m/%d/') + self.slug
  end

  def after_find
    open("#{Post::FILESTORE}/#{filename}") do |file|
      @title = file.gets.chomp
      @content = file.read
    end
  rescue
  end

  def author
    author = {}

    # parse the various signatures that have been employed by intertwingly.net
    # over the years...
    case @content
    when /(?:<br \/>\s<br \/>\s)?Posted by (.*)/
      author[:name] = $1
    when /\n<br \/><br \/>Excerpt from (.*)/
      author[:name] = $1
    when /(?:<a href="(\S+)">\[more\]<\/a>)?<br \/><br \/>Trackback from (.*)/
      author[:uri] = $1
      author[:name] = $2
    when /(?:<br \/><br \/>)?Pingback from (.*)/
      author[:name] = $1
    when /\n+<br \/><br \/>Emailed by (.*)/
      author[:name] = $1
    when /(?:<br \/><br \/>\s)?Message from (.*)/
      author[:name] = $1
    when /\n<br \/><br \/>Seen on (.*)/
      author[:name] = $1
    end

    # capture signature
    if $~
      @sig = @content[$~.begin(0)..-1]
    end

    # parse hypertext links
    if author[:name] =~ /<a( .*?)>(.*)<\/a>$/
      author[:name] = $2
      attrs = Hash[*$1.scan(/ (\w+)="(.*?)"/).flatten]
      author[:uri] = attrs['href'] if attrs['href']
      if attrs['class'] == 'openid'
        author[:openid] = attrs['title']
      else
        author[:ipaddr] = attrs['title']
      end
    end

    # parse email addresses
    if author[:uri] =~ /^mailto:(.*)/
      author[:email] = $1
      author.delete :uri
    end

    author
  end

  def anchor
    'c' + slug.split('-').last
  end
end
