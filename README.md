RSpec Hollerback Mocks
==========

[![Build Status](https://travis-ci.org/delner/rspec-hollerback-mocks.svg?branch=master)](https://travis-ci.org/delner/rspec-hollerback-mocks) ![Gem Version](https://img.shields.io/gem/v/rspec-hollerback-mocks.svg?maxAge=2592000)
###### *For Ruby 2+, RSpec 3+*

### Introduction

Adds mocking extensions to RSpec for testing code that implements Hollerback.

### Installation

##### If you're not using Bundler...

Install the gem via:

```
gem install rspec-hollerback-mocks
```

Then require it in your `spec_helper.rb` with:

```
require 'rspec/hollerback/mocks'
```

##### If you're using Bundler...

Add the gem to your Gemfile:

```
gem 'rspec-hollerback-mocks'
```

Then `bundle install` to install the gem and its dependencies.

Finally require it in your `spec_helper.rb` with:

```
require 'rspec/hollerback/mocks'
```

### Usage

##### Triggering a callback using and_callback

Given a class that implements Hollerback, e.g:

```ruby
class NoteApi
  include Hollerback

  # Callback-enabled function
  def get_note(&block)
    # ...
  end
end
```

You can mock callbacks on the class, or objects of the class using the `and_callback` condition.

```ruby
context "for a class" do
  subject do
    NoteApi.get_note do |on|
      on.success { "Success!" }
    end
  end
  it do
    expect(NoteApi).to receive(:get_note).and_callback(:success)
    expect(subject).to eq("Success!")
  end
end

context "for an object" do
  let(:client) { NoteApi.new }
  subject do
    client.get_note do |on|
      on.success { "Success!" }
    end
  end
  it do
    expect(client).to receive(:get_note).and_callback(:success)
    expect(subject).to eq("Success!")
  end
end
```

The mocked function will return the output of the callback block you invoke.

##### Chaining callbacks

You can also chain multiple callbacks, in which case the last callback will be the return value.

```ruby
context "for an object that invokes multiple callbacks" do
  let(:client) { NoteApi.new }
  subject do
    client.get_note do |on|
      on.created { "Created new note!" }
      on.success { "Success!" }
    end
  end
  it do
    expect(client).to receive(:get_note).and_callback(:created).and_callback(:success)
    expect(subject).to eq("Success!")
  end
end
```

##### Returning a value after callbacks

If you want the mocked function to return a different value, then you can add RSpec's `and_return` to the end of the call.

```ruby
context "for an object that invokes a callback and returns a value" do
  let(:note) { Note.new }
  let(:client) { NoteApi.new }
  subject do
    client.get_note do |on|
      on.success { "Success!" }
    end
  end
  it do
    expect(client).to receive(:get_note).and_callback(:success).and_return(note)
    expect(subject).to eq(note)
  end
end
```

##### Mocking a class that uses a callback

This feature is most useful when you want to mock behavior on a class that consumes the callback-enabled class.

For example, let's say there is a `NoteApi#get_note` function that makes HTTP requests and triggers callbacks. Let's also say we wanted to use this `NoteApi` to power a feature that adds signatures to our notes.

```ruby
class Autopen
  def self.get_signed_note(note_id, signature)
    note = NoteApi.get_note note_id do |on|
      # If the note exists, add a signature to it and return it
      on.found { |note| note.tap { |n| n.append(signature) } }

      # Otherwise just return a new note without a signature
      on.not_found { |note_id| Note.new(note_id) }
    end
  end
end
```

If we are writing specs for `Autopen` to test the `get_signed_note` method, we aren't interested in testing `NoteApi`. More importantly, we might not want that `NoteApi` class making actual HTTP calls that might make our test suite brittle, or otherwise slow it down.

This is where a mock is appropriate and the `and_callback` condition is most useful. Using it, we can implement a test that allows us to make the `NoteApi` trigger any callbacks we need to test the code we care about inside `get_signed_note`.

```ruby
describe Autopen do
  describe "#get_signed_note" do
    subject { Autopen.get_signed_note(note_id, signature) }
    let(:note_id) { "TPS Report" }
    let(:signature) { "Peter Gibbons\nSoftware Engineer\nInitech" }

    context "for a note that exists" do
      let(:note) { Note.new("Yes, I already got the memo.") }
      before(:each) { expect_any_instance_of(NoteApi).to receive(:get_signed_note).with(note_id).and_callback(:found, note) }
      it { is_expected.to eq(note) }
      it { expect(subject.body).to end_with(signature) }
    end
    context "when given a note that does not exist" do
      before(:each) { expect_any_instance_of(NoteApi).to receive(:get_signed_note).with(note_id).and_callback(:not_found, note_id) }
      it { expect(subject.body).to_not end_with(signature) }
    end
  end
end
```

## Development

Install dependencies using `bundle install`. Run tests using `bundle exec rspec`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/delner/rspec-hollerback-mocks.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

