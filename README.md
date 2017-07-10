# Jbuilder::Jpartial

Simple DSL for faster partial rendering with Jbuilder.

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

#### In `app/helpers/jpartial.rb`

```ruby
module Jbuilder::Jpartial
  jpartial :_post do |post|
    json.title post.title
    json.author post.author.name
    json.content post.content
    json.set! :comments do |comment|
      _comment comment
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
json.set! @posts do |post|
  json.jpartial._post post
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
When traditional partials are used with `Jbuilder`, with each partial in a different file using standard Rails conventions, render times and memory usage can skyrocket quickly with the number of records.

Using a simple DSL, `Jbuilder::Jpartial` lets you define all partials in one helper file and call them wherever you need them: from within other partial definitions or anywhere you use `Jbuilder`.

The result is faster rendering and lower memory usage. In the above example, if we had used traditional partials (defined in `app/views/posts/_post.jbuilder` and `app/views/posts/_comment.jbuilder`) those templates would have to be rendered once for each `post` and/or `comment`. Using `Jbuilder::Jpartial`, only one file (`app/views/posts/index.jbuilder`) is rendered. All of the partial rendering is taken care of in the abstract.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/msimonborg/jbuilder-jpartial.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

