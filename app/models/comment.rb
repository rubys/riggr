class Comment < ActiveRecord::Base
  attr_accessor :title, :content
  belongs_to :post

  def self.import! filename
    comment = Comment.new
    comment.created_at = File.stat(filename).mtime
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
    if @content =~ /(?:<br \/>\s<br \/>\s)?Posted by (.*)/
      name = $1
    elsif @content =~ /\n<br \/><br \/>Excerpt from (.*)/
      name = $1
    else
      name = '?'
    end

    if name =~ /<a (.*?)>(.*)<\/a>$/
      $2
    else
      name
    end
  end
end
