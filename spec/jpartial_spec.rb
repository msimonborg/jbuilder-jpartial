# frozen_string_literal: true

require 'jbuilder/jpartial'
require 'json'
require 'ostruct'
require 'pry'

User = Struct.new(:name, :age, :hometown, :posts)
Post = Struct.new(:id, :content, :comments)
Comment = Struct.new(:body)

describe Jbuilder::Jpartial do
  after :each do
    [:_user, :_post, :_comment].each do |method|
      Jbuilder.send(:undef_method, method) if Jbuilder.method_defined?(method)
    end
  end

  let! :user do
    User.new('name', 'age', 'hometown', (0..9).map do |p_num|
      Post.new(p_num, "Post #{p_num} content", (0..9).map do |c_num|
        Comment.new("Post #{p_num} comment #{c_num} body")
      end)
    end)
  end

  it 'defines instance methods on the Jbuilder class' do
    Jbuilder::Jpartial.configure do |jpartial|
      jpartial._user { |user| json.name user.name }
    end

    expect(Jbuilder.instance_method(:_user).arity).to be 1
  end

  it 'can use a non-block syntax' do
    expect { Jbuilder.instance_method(:_user) }.to raise_error NameError

    jpartial = Jbuilder::Jpartial::Template.new
    jpartial._user { |user| json.name user.name }

    expect(Jbuilder.instance_method(:_user).arity).to be 1
  end

  it 'raises if a method by that name is already defined by Jbuilder' do
    jpartial_block = lambda do |name|
      Jbuilder::Jpartial.configure do |jpartial|
        jpartial.send(name) { |user| json.name user.name }
      end
    end

    error = Jbuilder::Jpartial::DangerousMethodName

    expect { jpartial_block.call(:_user) }.not_to raise_error
    expect { jpartial_block.call(:_user) }.not_to raise_error

    expect { jpartial_block.call(:set!) }.to raise_error error
  end

  it 'formats JSON correctly' do
    Jbuilder::Jpartial.configure do |jpartial|
      jpartial._user do |user|
        json.name user.name
        json.age user.age
        json.hometown user.hometown
      end
    end

    response = JSON.parse(Jbuilder.encode { |json| json._user user })

    %w[name age hometown].each do |attr|
      expect(response[attr]).to eq user.send(attr)
    end
  end

  it 'can detect and evaluate ActionView route helper methods' do
    JbuilderTemplateDouble = Class.new(Jbuilder) do
      def initialize(context, *args)
        @context = context
        super(*args)
      end
    end

    Jbuilder::Jpartial.configure do |jpartial|
      jpartial._post do |post|
        json.name post.to_s
        json.url posts_url
      end
    end

    json = Jbuilder.new

    expect(json._method_is_a_route_helper?(:posts_url)).to be false

    context = OpenStruct.new(posts_url: 'www.app.com/posts')
    json = JbuilderTemplateDouble.new(context)

    expect(json._method_is_a_route_helper?(:posts_url)).to be true
    expect(json._method_is_a_route_helper?(:users_url)).to be false

    json._post :post
    response = JSON.parse(json.target!)

    expect(response['name']).to eq 'post'
    expect(response['url']).to eq 'www.app.com/posts'
  end

  it 'can embed partials and use keyword arguments' do
    Jbuilder::Jpartial.configure do |jpartial|
      jpartial._user do |user|
        json.name user.name
        json.age user.age
        json.hometown user.hometown
        json.set! 'posts', user.posts do |post|
          json._post post, author: user
        end
      end

      jpartial._post do |post, options = {}|
        author = options.fetch(:author)
        json.id post.id
        json.content post.content
        json.author author.name
        json.set! 'comments', post.comments do |comment|
          json._comment comment, post: post
        end
      end

      jpartial._comment do |comment, options = {}|
        post = options.fetch(:post)
        json.body comment.body
        json.post_id post.id
      end
    end

    response = JSON.parse(Jbuilder.encode { |json| json._user user })

    %w[name age hometown].each do |attr|
      expect(response[attr]).to eq user.send(attr)
    end

    posts = response['posts']

    expect(posts).to be_a Array
    expect(posts.length).to eq 10

    posts.each_with_index do |post, p_index|
      expect(post['id']).to eq p_index
      expect(post['content']).to eq "Post #{p_index} content"
      expect(post['comments']).to be_a Array
      expect(post['comments'].length).to eq 10

      post['comments'].each_with_index do |comment, c_index|
        expect(comment['body']).to eq "Post #{p_index} comment #{c_index} body"
        expect(comment['post_id']).to eq p_index
      end
    end
  end
end
