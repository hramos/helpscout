## Usage

1. Follow the instructions at [Help Scout's Developers site](http://developer.helpscout.net/) to generate an API key.

2. Initialize your HelpScout client

```ruby
hs = HelpScout.new(HELPSCOUT_API_KEY)
```

#### Fetching Users

```ruby
users = hs.users
```

#### Fetching Mailboxes

```ruby
mailboxes = hs.mailboxes
```

#### Fetching Customers

```ruby
customers = hs.customers
```

#### Fetching Conversations

To fetch active conversations:

```ruby
conversations = hs.conversations(mailbox.id, {:status => "active"})
```

You may query for "all", "active", or "pending" conversations. Default is "all".
