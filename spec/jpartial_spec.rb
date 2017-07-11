# frozen_string_literal: true

require 'jbuilder/jpartial'
require 'json'
require 'pry'

User = Struct.new(:name, :age, :hometown, :posts)
Post = Struct.new(:content, :comments)
Comment = Struct.new(:body)

describe Jbuilder::Jpartial do
  after :each do
    [:_user, :_post, :_comment].each do |method|
      Jbuilder.send(:undef_method, method) if Jbuilder.method_defined?(method)
    end
  end

  let! :user do
    User.new('name', 'age', 'hometown', (1..10).map do |post_num|
      Post.new("Post #{post_num} content", (1..10).map do |comment_num|
        Comment.new("Post #{post_num} comment #{comment_num} body")
      end)
    end)
  end

  it 'defines instance methods on the Jbuilder class' do
    Jbuilder::Jpartial.configure do
      jpartial(:_user) { |user| json.name user.name }
    end

    expect(Jbuilder.instance_method(:_user).arity).to be 1
  end

  it 'raises an error if a method by that name is already defined' do
    jpartial_block = lambda do
      Jbuilder::Jpartial.configure do
        jpartial(:_user) { |user| json.name user.name }
      end
    end

    error = Jbuilder::Jpartial::DangerousMethodName

    expect { jpartial_block.call }.not_to raise_error

    expect { jpartial_block.call }.to raise_error error
  end

  it 'formats JSON correctly' do
    Jbuilder::Jpartial.configure do
      jpartial(:_user) do |user|
        json.name user.name
        json.age user.age
        json.hometown user.hometown
      end
    end

    response = JSON.parse(Jbuilder.encode { |json| json._user user })

    expect(response['name']).to eq user.name
    expect(response['age']).to eq user.age
    expect(response['hometown']).to eq user.hometown
  end

  it 'can embed partials and use keyword arguments' do
    Jbuilder::Jpartial.configure do
      jpartial(:_user) do |user|
        json.name user.name
        json.age user.age
        json.hometown user.hometown
      end
    end
  end
end
