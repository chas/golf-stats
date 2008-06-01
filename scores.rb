require 'rubygems'
require 'sinatra'
require 'active_record'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => "scores.db")

begin

  # define database schema
  ActiveRecord::Schema.define do
    create_table :scores do |t|
      t.integer :course_id
      t.integer :score
      t.timestamps
    end

    create_table :courses do |t|
      t.string :name
      t.integer :user_id
      t.timestamps
    end

    create_table :users do |t|
      t.string :login
      t.string :password
      t.string :name
      t.timestamps
    end

  end
rescue ActiveRecord::StatementInvalid
end



class Score < ActiveRecord::Base
  belongs_to :course
end

class Course < ActiveRecord::Base
  has_many :scores, :dependent => :destroy
end

class User < ActiveRecord::Base
  has_many :courses, :dependent => :destroy
end



get '/' do
  # just find and show all the scores
  find_courses
  @scores = Score.find(:all, :order => :created_at)
  @average_score = Score.average(:score)
  erb :index
end

post '/' do
  course_name = (params[:course_select].blank? ? params[:course] : params[:course_select])
  course = Course.find_or_create_by_name(course_name)

  # post a new score
  @score = Score.new(
    :course_id => course.id,
    :score => params[:score]
  )
  
  @score.save
  redirect '/'
end


# courses CRUD
get '/courses' do
  find_courses
  erb :courses
end

get '/course/:id' do
  find_course(params[:id])
  erb :course
end

put '/course/:id' do
  find_course(params[:id])

  @course.update_attributes(:name => params[:name])
  @course.save!
  redirect "/course/#{@course.id}"
end

delete '/course/:id' do
  @course = Course.find(params[:id])  
  @course.destroy
  redirect '/courses'
end

# users
get '/users' do
  find_users
  erb :users
end

get '/user/:id' do
  find_by_id(params[:id])
  erb :user
end



# DRY
def find_courses
  @courses = Course.find(:all, :order => :name)
end

def find_course(id)
  @course = Course.find(id)
end

# # set utf-8 for outgoing
before do
  header "Content-Type" => "text/html; charset=utf-8"
end
