require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase
  def setup
    # create an index entry
    @comment = Comment.new
    @comment.created_at = Time.utc(2008,06,21,12,34,56)
    @comment.slug = '123456'
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
end
