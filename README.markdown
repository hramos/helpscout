# Helpscout Developers API gem

This gem is in beta.

## Usage

1. Follow the instructions at [Help Scout's Developers site](http://developer.helpscout.net/) to generate an API key.

2. Initialize your HelpScout client

```ruby
helpscout = HelpScout::Client.new(HELPSCOUT_API_KEY)
```

#### Fetching Users

```ruby
users = helpscout.users
```

#### Fetching Mailboxes

```ruby
mailboxes = helpscout.mailboxes
```

#### Fetching Customers

```ruby
customers = helpscout.customers
```

#### Fetching Conversations

To fetch active conversations:

```ruby
conversations = helpscout.conversations(mailboxId, "active", nil)
```

