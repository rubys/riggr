class BlogController < ApplicationController
  before_filter :set_content_type
  def set_content_type
    response.headers['content-type'] = 'application/xhtml+xml'
  end


  def index
    @posts = Post.find(:all, :order => 'created_at desc', :limit => 10)
  end

  def post
    date = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    @post = Post.find(:first,
      :conditions => ['created_at >= ? and created_at < ?', date, date+1])
    @comments = Comment.find(:all, :order => 'created_at asc',
      :conditions => ['post_id = ?', @post])
  end

  def comments
    @comments = Comment.find(:all, :order => 'created_at desc', :limit => 20)
  end

  def archives
    year = (params[:year] || Date.today.year).to_i
    month = (params[:month] || Date.today.month).to_i

    @date = Date.new(year,month,1)
    @calendar, d, last = [], @date-1, 7
    while (d+=1).month == month
      @calendar.push week = [0]*7 if d.wday < last
      week[last = d.wday] = d.day
    end

    @entries = Post.find(:all, :order=>'created_at desc',
      :conditions => ['created_at >= ? and created_at < ?', @date, d-1])
  end

  def test
    @calendar = true # kill navbar
  end
end
