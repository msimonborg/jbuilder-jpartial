# Jbuilder::Jpartial

A lightweight library that provides a simple DSL for faster partial rendering with Jbuilder.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'jbuilder-jpartial', require: 'jbuilder/jpartial'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jbuilder-jpartial
    
    require 'jbuilder/jpartial'

## Usage

#### In `config/initializers/jbuilder-jpartial.rb`

```ruby
Jbuilder::Jpartial.configure do
  jpartial :_post do |post|
    json.title post.title
    json.author post.author.name
    json.content post.content
    json.set! 'comments', post.comments do |comment|
      json._comment comment
    end
  end
  
  jpartial :_comment do |comment|
    json.content comment.content
    json.author comment.author.name
  end
end
```

#### In `app/views/posts/index.jbuilder`

```ruby
json.set! 'posts', @posts do |post|
  json._post post
end
```

#### Result:
```js
{
    "posts": [
        {
            "title": "The Best of Posts",
            "author": "M. Simon Borg",
            "content": "Pizza time!",
            "comments": [
                { "content": "So good", "author": "Matt's mom" },
                { "content": "I agree", "author": "Matt's dad" }
            ]
        }
    ]   
}
```
#### Why?
When traditional partials are used with `Jbuilder`, with each partial in a different file using standard Rails conventions, render times and memory usage can skyrocket quickly with the number of records, i.e. the number of partials rendered.

Using a simple DSL, `Jbuilder::Jpartial` lets you define all partials in one initializer file and call them wherever you need them: from within other partial definitions or anywhere you use `Jbuilder` in your views.

The result is faster rendering and lower memory usage, while still being able to leverage the advantages of Jbuilder. In the above example, if we had used traditional partials (defined in `app/views/posts/_post.jbuilder` and `app/views/comments/_comment.jbuilder`) those templates would have to be rendered once for each `post` and/or `comment`. If you have 50 posts, each with 50 comments, that's 2,500 templates rendered! Using `Jbuilder::Jpartial`, only one file (`app/views/posts/index.jbuilder`) is rendered. All of the partial rendering is taken care of in the abstract.

#### How?
Each `jpartial` block in your initializer file defines a Jbuilder method named after whatever symbol you pass as an argument. The objects you will pass to that method are yielded to the block. Inside the block you can use plain old Jbuilder syntax.

e.g.

```ruby
Jbuilder::Jpartial.configure do
  jpartial :_post do |post|
    json.title post.title
  end
end
```

Now in your `.jbuilder` templates you can call `json._post @post`.

You can specify multiple arguments and even use keyword arguments if you need to pass more than one local variable to the partial. You can also call partial methods from within other partial methods.

e.g.

```ruby
Jbuilder::Jpartial.configure do
  jpartial :_post do |post, author:|
    json.title post.title
    json._author author
  end
  
  jpartial :_author do |author|
    json.name author.name
  end
end
```

Now you can call `json._post @post, author: @author`

Route helpers that are available within the views can also be used in the configuration file.

e.g.

```ruby
Jbuilder::Jpartial.configure do
  jpartial :_post do |post|
    json.href post_url(post)
    json.title post.title
  end
end
```

However unlikely, if you try to name a partial with the same name as a method already defined by Jbuilder it will throw an error at start up. Just pick a different name, like `#set_partial!` instead of `#set!`.


## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/msimonborg/jbuilder-jpartial.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

