class Comment < ActiveRecord::Base
  attr_accessor :title, :content
  belongs_to :post

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
