module BlogHelper
  def comment_link(post)
    comments = post.comments.size

    if comments == 0
      text = "Add comment"
    elsif comments == 1
      text = '1 comment'
    else
      text = "#{comments} comments"
    end

    link_to text, date_url(:year => post.created_at.year,
      :month => post.created_at.month, :day => post.created_at.day,
      :slug => post.slug)
  end

  def comment_header(comment)
    date = comment.created_at.strftime('%Y-%m-%d')
    if @last_header_date != date
      @last_header_date = date
      "<h2><time title='GMT' datetime='#{date}'>" +
        "#{comment.created_at.strftime('%a %d %b %Y')}</time></h2>"
    end
  end

  def comment_title(comment)
    @post_title ||= comment.post.title
    if comment.title != @post_title
      "<h3>#{comment.title}</h3>"
    end
  end
end
