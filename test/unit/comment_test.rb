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
    File.utime @comment.created_at, @comment.created_at, 'tmp/import_42.cmt'
    Comment.import! 'tmp/import_42.cmt'

    # verify results
    @comment = Comment.find(:first, :conditions => ['slug = ?', 'import_42'])
    assert_equal 'loren', @comment.title
    assert_equal Time.utc(2008,06,21,12,34,56), @comment.created_at
    assert_equal '2008/06/21/import_42', @comment.filename
  ensure
    File.unlink('tmp/import_42.cmt')
  end
end
