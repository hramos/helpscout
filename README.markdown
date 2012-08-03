# Helpscout Developers API gem

This gem is in alpha.

## Usage

1. Follow the instructions at [Help Scout's Developers site](http://developer.helpscout.net/) to generate an API key.

2. Initialize your HelpScout client

```ruby
HelpScout::Base.load!(HELPSCOUT_API_KEY)
```

#### Fetching Users

```ruby
users = HelpScout::Base.users
```

#### Fetching Mailboxes

```ruby
mailboxes = HelpScout::Base.mailboxes
```

#### Fetching Customers

```ruby
customers = HelpScout::Base.customers
```

#### Fetching Conversations

To fetch active conversations:

```ruby
conversations = HelpScout::Base.conversations(mailboxId, {:status => "active"})
```

You may query for "all", "active", or "pending" conversations. Default is "all".
