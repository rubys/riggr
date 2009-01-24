module BlogHelper
  def post_url(post, overrides={})
    options = {:year => post.created_at.year,
      :month => '%0.2d' % post.created_at.month,
      :day => '%0.2d' % post.created_at.day, :slug => post.slug}
    if response_html?
      options['format'] = 'html'
      format_date_url(options.update(overrides))
    else
      date_url(options.update(overrides))
    end
  end

  def comment_url(comment)
    post_url(comment.post, :anchor => comment.anchor)
  end

  def comment_link(post, anchor='comments')
    comments = post.comments.size

    text = (comments == 0 ? 'Add comment' : pluralize(comments, 'comment'))

    link_to text, post_url(post, :anchor=>anchor)
  end

  def section_header(comment)
    date = comment.created_at.strftime('%Y-%m-%d')
    if @last_header_date != date
      section = "<section>\n"
      section = "</section>\n\n" + section if @last_header_date
      @last_header_date = date
      "#{section}<header>\n" +
      "<h2><time title='GMT' datetime='#{date}'>" +
        "#{comment.created_at.strftime('%a %d %b %Y')}</time></h2>\n" +
      "</header>\n"
    else
      "\n<hr/>\n"
    end
  end

  def close_section
    "</section>\n" if @last_header_date
  end

  def comment_title(comment)
    @post_title ||= comment.post.title
    if comment.title != @post_title
      "<header><h3>#{comment.title}</h3></header>\n"
    end
  end

  def text_construct(xml, entry, field)
    data = entry.send field
    if data =~ /&|</
      div = "<div xmlns='http://www.w3.org/1999/xhtml'>#{data}</div>\n"
      begin
        doc = REXML::Document.new div
        xml.instance_eval "#{field} :type=>'xhtml', &proc {|x| x<<doc.to_s}"
      rescue
        xml.instance_eval "#{field} div, :type=>'html'"
      end
    else
      xml.instance_eval "#{field} data"
    end
  end

  def response_html?
    response.headers['content-type'] != 'application/xhtml+xml'
  end
end
