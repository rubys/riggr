require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase
  def setup
    # create an index entry
    @comment = Comment.new
    @comment.created_at = Time.utc(2008,06,21,12,34,56)
    @comment.slug = '123456'
  end

  def teardown
    FileUtils.rm_rf Post::FILESTORE
  end

  def test_filename
    assert_equal '2008/06/21/123456', @comment.filename
  end

  def test_file_backingstore
    # save the index entry and create the corresponding file
    @comment.save!
    filename = "#{Post::FILESTORE}/#{@comment.filename}"
    FileUtils.mkdir_p File.dirname(filename)
    open(filename,'w') { |file| file.write "loren\nipsum\n" }

    # verify that the file augments the model after a find occurs
    @comment = Comment.find(:first, :conditions => ['slug = ?', '123456'])
    assert_equal 'loren', @comment.title
    assert_equal "ipsum\n", @comment.content
  end

  def test_import
    # import a test file
    open('tmp/import_42.cmt','w') { |file| file.write("loren\n\ipsum\n") }
    localtime = @comment.created_at.localtime
    File.utime localtime, localtime, 'tmp/import_42.cmt'
    Comment.import! 'tmp/import_42.cmt'

    # verify results
    @comment = Comment.find(:first, :conditions => ['slug = ?', 'import_42'])
    assert_equal 'loren', @comment.title
    assert_equal Time.utc(2008,06,21,12,34,56), @comment.created_at
    assert_equal '2008/06/21/import_42', @comment.filename
  ensure
    File.unlink('tmp/import_42.cmt')
  end

  # support for test_author
  def import(string)
    open('tmp/import.cmt','w') { |file| file.write("\n" + string) }
    Comment.import! 'tmp/import.cmt'
    @comment = Comment.find(:first, :conditions => ['slug = ?', 'import'])
  end

  def test_author
    import "text\n<br /><br />Excerpt from site\n"
    assert_equal 'site', @comment.author[:name]

    import "text<br /><br />Posted by name\n"
    assert_equal 'name', @comment.author[:name]

    import "text\n<a href=\"http://example.com/\">[more]</a>" +
      "<br /><br />Trackback from site\n"
    assert_equal 'site', @comment.author[:name]

    import "Pingback from site\n"
    assert_equal 'site', @comment.author[:name]

    import "text\n<br /><br />Emailed by name\n"
    assert_equal 'name', @comment.author[:name]

    import "text\n<br /><br />Message from name\n"
    assert_equal 'name', @comment.author[:name]

    import "text\n<br /><br />Seen on site\n"
    assert_equal 'site', @comment.author[:name]

    import 'text<br /><br />Posted by <a title="http://site.com/id" ' +
      'class="openid" href="http://site.com/">name</a>'
    assert_equal 'name', @comment.author[:name]
    assert_equal 'http://site.com/', @comment.author[:uri]
    assert_equal 'http://site.com/id', @comment.author[:openid]

    import 'text<br /><br />Posted by <a title="1.2.3.4" ' +
      'href="mailto:name@site.com">name</a>'
    assert_equal 'name', @comment.author[:name]
    assert_equal 'name@site.com', @comment.author[:email]
    assert_equal '1.2.3.4', @comment.author[:ipaddr]

  ensure
    File.unlink('tmp/import.cmt')
  end
end
