# Seria

[![Gem Version](https://badge.fury.io/rb/seria.svg)](http://badge.fury.io/rb/seria)

## Why?
I wrote this gem because I needed to be able to load my ARs with key-value attributes without running migrations,
in a similar way to [dynamic_attributes](https://github.com/moiristo/dynamic_attributes) gem.
But I also needed to be able to query the data, so storing it in a JSON wasn't a good enough solution.
There were still mongodb documents, but I wanted to be able to run join queries, and exporting data to another database
was an overkill.

Seria lets you add completely dynamic data to your ARs.
Seria doesn't store your hash data in a JSON, but in separate records making it queryable.
Seria will automatically cast your attributes back to their original type when loaded from the database -
no more messy string manipulations.


## Installation

Add this line to your application's Gemfile:

    gem 'seria'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install seria

## Usage

### Generate the info table

    $ rails g info_table book
    $ rake db:migrate

### Register your info table owner and start loading attributes

```ruby

class Book < ActiveRecord::Base
  include Seria::InfoTableOwner
end

book = Book.new(title: "The portable")
book.infos["price"]=100.0
book.infos["author"] = 'Dorothy Paker'
book.infos["recommended"] = true
book.save

book = Book.last
book.infos["price"]
=> 100.0
book.infos["recommended"]
=> true

```

### Or, avoid awkward association syntax and call directly

```ruby
Seria.configure do |config|
  config.perform_lookup_on_method_missing = true
end

book.recommended = false
book.recommended
=> false

```

### Querying

Seria stores your data in separate table with the fields foreign_id, field_name, field_value and field_type

```sql
/* The values are saved as strings, so when querying the database you need to convert to your original type: */
select CAST(field_value as decimal(10,2)) as price from book_infos where field_name = "price"
```

```ruby
class BookInfo #yes, you can define yourself
  scope :prices, proc{ where('field_name="price"') }
end

cheep_books = BookInfo.prices.where('CAST(field_value as decimal(10,2)) < 10') #database
cheep_books = BookInfo.prices.select{|p| p.field_value < 10} #memory

```

### Configure your own table-names, fields and converters

```ruby
Seria.configure do |config|
  config.fields.key = :fkey
  config.fields.value = :fvalue
  config.fields.type = :ftype
  config.descriptor = :data
  config.converters["price"] = Seria::BigDecimalConverter
end
```



## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
