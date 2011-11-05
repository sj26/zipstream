# ZipStream

Create zip files to a stream.

Integration with Ruby on Rails means you can create a file, `index.zipstream`, which is a ruby file with a zip object:

```ruby
@entries.each do |entry|
  zip.write "entry-#{entry.id}.txt", entry.to_s
end
```

Which will happily implicitly render from:

```ruby
class EntriesController
  def index
    @entries = Entry.all
  end
end
```

Giving you a zip file when rendered. More to come!

## Caveats

Keep in mind that this will use one of your workers/threads/processes until the file is completely downloaded. We are using an iterated rack body which streams so if rack/web servers handle this nicely then you might be in luck.

Tested with Rails 3.1 on REE 1.8.7 and MRI 1.9.3. Specs coming soon (tm).

## Thanks

Inspired by http://pablotron.org/software/zipstream-php/

## License

Copyright (c) 2011 Samuel Cochran (sj26@sj26.com). Released under the MIT License, see [LICENSE][license] for details.

  [license]: https://github.com/sj26/zipstream/blob/master/LICENSE