# Jbuilder::Jpartial

[![Gem Version](https://badge.fury.io/rb/jbuilder-jpartial.svg)](https://badge.fury.io/rb/jbuilder-jpartial)
[![Code Climate](https://codeclimate.com/github/msimonborg/jbuilder-jpartial/badges/gpa.svg)](https://codeclimate.com/github/msimonborg/jbuilder-jpartial)
[![Build Status](https://travis-ci.org/msimonborg/jbuilder-jpartial.svg?branch=master)](https://travis-ci.org/msimonborg/jbuilder-jpartial)

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

#### In `app/views/posts/_post.jbuilder`

```ruby
jpartial._post do |post|
  json.title post.title
  json.author post.author.name
  json.content post.content
  json.partial! 'comments/comment'
  json.set! 'comments', post.comments do |comment|
    json._comment comment
  end
end
```

#### In `app/views/comments/_comment.jbuilder`
```ruby
jpartial._comment do |comment|
  json.content comment.content
  json.author comment.author.name
end
```

#### In `app/views/posts/index.jbuilder`

```ruby
json.partial! 'post'
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
When partials are used with `Jbuilder` render times and memory usage can skyrocket quickly with the number of records, i.e. the number of partials rendered.

Using a simple DSL, `Jbuilder::Jpartial` lets you define your partials in a familiar way while dramatically reducing overhead.

The result is faster rendering and lower memory usage, while still being able to leverage the advantages of Jbuilder. In the above example, if we had used standard Jbuilder partials those templates would have to be rendered once for each `post` and/or `comment`. If you have 50 posts, each with 50 comments, that's 2,550 templates rendered! Using `Jbuilder::Jpartial`, the partial files are each only called when the partial is initialized. After that, all of the partial rendering is taken care of in the abstract from the original file. In our example, we hit `json.partial! 'post'` once and `json.partial! 'comments/comment'` only once for each `post`, cutting 2,550 template renders down to 51.

Alternatively you can define all partials in one initializer file and call them wherever you need them: from within other partial definitions or anywhere you use `Jbuilder` in your views. The big advantage here is since they're initialized at start up, you don't need to call any additional view templates to render the partials. Using the same example as above:

#### First generate the file

    $ rails generate jpartial


#### Then in `app/config/initializers/jpartial.rb`
```ruby
Jbuilder::Jpartial.configure do |jpartial|
  jpartial._post do |post|
    json.title post.title
    json.author post.author.name
    json.content post.content
    json.set! 'comments', post.comments do |comment|
      json._comment comment
    end
  end

  jpartial._comment do |comment|
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

Notice that when using this method, we don't make any calls like `json.partial! 'post'` at any point to define the partial before using it. All of the partials are already defined in the initializer file.

We've now cut our template renders down to only 1 from the original 2,550. The only real disadvantage is it bucks the regular Rails file structure conventions for partials. C'est la vie.

#### How?
Each method you call on `jpartial`  defines a Jbuilder method of the same name. The objects you will pass to that method are yielded to the block. Inside the block you can use plain old Jbuilder syntax, and access any of the helper methods available in your views.

e.g.

```ruby
jpartial._post do |post|
  json.post_url post_url(post)
end
```

Now in your `.jbuilder` templates you can call `json._post @post`.

You can specify multiple arguments and even use keyword options if you need to pass more than one local variable to the partial. You can also call partial methods from within other partial methods.

The rule of thumb when defining your partials in view templates is you need to make sure the partial is initialized by making a call to the template, outside of your render logic and/or any loops/iteration.

e.g.

#### `app/views/authors/_author.jbuilder`
```ruby
jpartial._author do |author|
  json.name author.name
end
```

#### `app/views/posts/_post.jbuilder`
```ruby
jpartial._post do |post, author:|
  json.title post.title
  json.partial! 'authors/author'
  json._author author
end
```

Now you can call `json._post @post, author: @author`

Again, if you're defining all of your partials in one config file (best performance), the extra call to a partial template is not necessary.

#### `config/initializers/jpartial.rb`
```ruby
Jbuilder::Jpartial.configure do |jpartial|
  jpartial._post do |post, author:|
    json.title post.title
    json._author author
  end

  jpartial._author do |author|
    json.name author.name
  end
end
```

However unlikely, if you try to name a partial with the same name as a method already defined by Jbuilder it will throw an error at start up. Just pick a different name, like `#whatever_partial` instead of `#whatever`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/msimonborg/jbuilder-jpartial.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
