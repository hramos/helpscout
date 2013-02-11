# Help Scout API V1 Client
# http://developer.helpscout.net/
#
# Authentication
# This is an HTTPS-only API. Authentication will be based on API Keys, which can
# be generated the Help Scout UI in the User Profile. Each API Key will map to 
# an existing Help Scout user. Results returned from various responses will be 
# based upon the role of the user to which the API key is tied.
#
# The API Key will be passed via HTTP Basic Authentication. The API Key will go 
# in the username field and a dummy password, such as X, in the password field.
#
# Rate Limiting
# Requests will be limited to 200 requests per minute. Response code 429 will 
# be returned when throttle limit has been reached. A "Retry-After" header will
# be returned indicating how many seconds to wait until retry.
#
# Formats
# Each endpoint will specify the response format in the URL. However, the API
# will only support JSON at this time.
#
# Usage
# 1. Follow the instructions at Help Scout's Developers site to generate an API 
#    key: http://developer.helpscout.net/
# 2. Add your API Key to config/helpscout.yml:
#    api_key: XXXXXX
# 3. Initialize your Help Scout client:
#    HelpScout::Client.new
# 4. You may now query the Help Scout API:
#    mailboxes = HelpScout::Client.mailboxes
#
# You may also initialize a client without using helpscout.yml by passing the
# API Key to new:
# HelpScout::Client.new(XXXXXX)

require "erb"
require "httparty"
require "yaml"

module HelpScout
  class Client
    include HTTParty

    # All API requests will be made to: https://api.helpscout.net/. All 
    # requests are served over HTTPS. The current version is v1.
    base_uri 'https://api.helpscout.net/v1'

    @@settings ||= nil

    # Returns the current Help Scout Client settings.
    # If no settings have been loaded yet, this function will load its 
    # configuration from helpscout.yml
    # 
    # Settings
    # api_key  String  Help Scout API Key. The API is currently available for 
    #                  paying Help Scout accounts (Basic or Standard plan). You
    #                  can generate a key from your User Profile, on the API 
    #                  Keys tab.

    def self.settings
      if @@settings.nil?
        path = "config/helpscout.yml"
        if File.exist?(path)
          @@settings = YAML.load(ERB.new(File.new(path).read).result)
        end
      end
      @@settings
    end


    # Requests a single item from the Help Scout API. Should return either an 
    # item from the SingleItemEnvelope, or raise an error with an 
    # ErrorEnvelope.
    #
    # url     String  A string representing the url for the REST endpoint to be
    #                 queried.
    # params  Hash    A hash of GET parameters to use for this particular 
    #                 request.
    #
    # Response
    #           Name    Type   Notes     
    #  Header   Status  Int    200
    #  Body     item

    def self.requestItem(auth, url, params={})
      item = nil

      request_url = ""
      request_url << url
      if params
        request_url << "?" + params.to_query
      end

      begin
        response = Client.get(request_url, {:basic_auth => auth})
      rescue SocketError => se
        raise StandardError, se.message
      end

      if 200 <= response.code && response.code < 300
        envelope = SingleItemEnvelope.new(response)
        if envelope.item
          item = envelope.item
        end
      elsif 400 <= response.code && response.code < 500
        if response["message"]
          envelope = ErrorEnvelope.new(response)
          raise StandardError, envelope.message
        else
          raise StandardError, response["error"]
        end
      else
        raise StandardError, "Server Response: #{response.code}"
      end

      item
    end


    # Requests a collections of items from the Help Scout API. Should return 
    # either an array of items from the CollectionsEnvelope, or raise an error 
    # with an ErrorEnvelope.
    # 
    # Collections return a maximum of 50 records per page.
    #
    # url     String  A string representing the url for the REST endpoint to be 
    #                 queried.
    # params  Hash    A hash of GET parameters to use for this particular 
    #                 request.
    #
    # Response
    #           Name    Type   Notes     
    #  Header   Status  Int    200
    #  Body     page    Int    Current page that was passed in on the request
    #           pages   Int    Total number of pages available
    #           count   Int    Total number of objects available
    #           items   Array  Collection of objects

    def self.requestItems(auth, url, params={})
      items = []

      request_url = ""
      request_url << url
      if params
        query = ""
        params.each { |k,v| query += "#{k}=#{v}&" }
        request_url << "?" + query
      end

      begin
        response = Client.get(request_url, {:basic_auth => auth})
      rescue SocketError => se
        raise StandardError, se.message
      end
    
      if 200 <= response.code && response.code < 300
        envelope = CollectionsEnvelope.new(response)
        if envelope.items
          envelope.items.each do |item|
            items << item
          end
        end
      elsif 400 <= response.code && response.code < 500
        if response["message"]
          envelope = ErrorEnvelope.new(response)
          raise StandardError, envelope.message
        else
          raise StandardError, response["error"]
        end
      else
        raise StandardError, "Server Response: #{response.code}"
      end

      items
    end
    

    # Requests a collections of items from the Help Scout API. Should return 
    # the total count for this collection, or raise an error with an 
    # ErrorEnvelope.
    # 
    # url     String  A string representing the url for the REST endpoint to be 
    #                 queried.
    # params  Hash    A hash of GET parameters to use for this particular 
    #                 request.
    #
    # Response
    #           Name    Type   Notes
    #  Header   Status  Int    200
    #  Body     page    Int    Current page that was passed in on the request
    #           pages   Int    Total number of pages available
    #           count   Int    Total number of objects available
    #           items   Array  Collection of objects

    def self.requestCount(auth, url, params={})
      request_url = ""
      request_url << url
      if params
        query = ""
        params.each { |k,v| query += "#{k}=#{v}&" }
        request_url << "?" + query
      end

      begin
        response = Client.get(request_url, {:basic_auth => auth})
      rescue SocketError => se
        raise StandardError, se.message
      end
    
      if 200 <= response.code && response.code < 300
        envelope = CollectionsEnvelope.new(response)
        envelope.count
      elsif 400 <= response.code && response.code < 500
        if response["message"]
          envelope = ErrorEnvelope.new(response)
          raise StandardError, envelope.message
        else
          raise StandardError, response["error"]
        end
      else
        raise StandardError, "Server Response: #{response.code}"
      end     
    end

    # HelpScout::Client.new
    # 
    # Initializes the Help Scout Client. Once called, you may use any of the 
    # HelpScout::Client methods to query the Help Scout API.
    #
    # key  String  Help Scout API Key. Optional. If not passed, the key will be
    #              loaded from @@settings, which defaults to helpscout.yml.

    def initialize(key = nil)
      Client.settings
  
      if key.nil?
        key = @@settings["api_key"]
      end

      # The Help Scout API uses Basic Auth, where username is your API Key. 
      # Password can be any arbitrary non-zero-length string.
      @auth = { :username => key, :password => "X" }
    end


    # Get User
    # http://developer.helpscout.net/users/
    #
    # Fetches a single user by id.
    #
    # userId  Int  id of the User being requested
    #
    # Request 
    #  REST Method: GET
    #  URL: https://api.helpscout.net/v1/users/{id}.json
    #
    # Response
    #  Name  Type
    #  item  User

    def user(userId)
      url = "/users/#{userId}.json"
      item = Client.requestItem(@auth, url, nil)
      user = nil
      if item
        user = User.new(item)
      end
      user
    end


    # List Users
    # http://developer.helpscout.net/users/
    #
    # Fetches all users
    #
    # Request 
    #  REST Method: GET
    #  URL: https://api.helpscout.net/v1/users.json
    #
    #  Parameters:
    #   Name  Type  Required  Default  Notes
    #   page  Int   No        1 
    #
    # Response
    #  Name   Type
    #  items  Array  Collection of User objects

    def users
      url = "/users.json"
      items = Client.requestItems(@auth, url, :page => 1)
      users = []
      items.each do |item|
        users << User.new(item)
      end
      users
    end


    # List Users by Mailbox
    # http://developer.helpscout.net/users/
    #
    # Fetches all users in a single mailbox
    #
    # mailboxId  Int  id of the Mailbox being requested
    #
    # Request 
    #  REST Method: GET
    #  URL: https://api.helpscout.net/v1/mailboxes/{id}/users.json
    #
    #  Parameters:
    #   Name  Type  Required  Default  Notes
    #   page  Int   No        1 
    #
    # Response
    #  Name   Type
    #  items  Array  Collection of User objects

    def usersInMailbox(mailboxId)
      url ="/mailboxes/#{mailboxId}/users.json"
      items = Client.requestItems(@auth, url, :page => 1)
      users = []
      items.each do |item|
        users << User.new(item)
      end
      users
    end


    # List Mailboxes
    # http://developer.helpscout.net/mailboxes/
    #
    # Fetches all mailboxes
    #
    # Request 
    #  REST Method: GET
    #  URL: https://api.helpscout.net/v1/mailboxes.json
    #
    #  Parameters:
    #   Name  Type  Required  Default  Notes
    #   page  Int   No        1 
    #
    # Response
    #  Name   Type
    #  items  Array  Collection of Mailbox objects

    def mailboxes
      url = "/mailboxes.json"
      mailboxes = []
      begin
        items = Client.requestItems(@auth, url, {})
        items.each do |item|
          mailboxes << Mailbox.new(item)
        end
      rescue StandardError => e
        print "List Mailbox Request failed: " + e.message
      end
      mailboxes
    end


    # Get Mailbox
    # http://developer.helpscout.net/mailboxes/
    #
    # Fetches a single Mailbox
    #
    # mailboxId  Int  id of the Mailbox being requested
    #
    # Request 
    #  REST Method: GET
    #  URL: https://api.helpscout.net/v1/mailboxes/{id}.json
    #
    # Response
    #  Name  Type
    #  item  Mailbox
    
    def mailbox(mailboxId)
      url = "/mailboxes/#{mailboxId}.json"
      item = Client.requestItem(@auth, url, nil)
      mailbox = nil
      if item
        mailbox = Mailbox.new(item)
      end
      mailbox
    end


    # Get Folders
    # http://developer.helpscout.net/mailboxes/
    #
    # Fetches all Folders in a given mailbox
    #
    # mailboxId  Int  id of the Mailbox being requested
    #
    # Request 
    #  REST Method: GET
    #  URL: https://api.helpscout.net/v1/mailboxes/{id}/folders.json
    #
    #  Parameters:
    #   Name  Type  Required  Default  Notes
    #   page  Int   No        1 
    #
    # Response
    #  Name   Type
    #  items  Array  Collection of Mailbox objects

    def foldersInMailbox(mailboxId)
      url = "/mailboxes/#{mailboxId}/folders.json"
      items = Client.requestItems(@auth, url, :page => 1)
      folders = []
      items.each do |item|
        folders << Folder.new(item)
      end
      folders
    end


    # Get Conversation
    # http://developer.helpscout.net/conversations/
    #
    # Fetches a single Conversation
    #
    # conversationId  Int  id of the Conversation being requested
    #
    # Request 
    #  REST Method: GET
    #  URL: https://api.helpscout.net/v1/conversations/{id}.json
    #
    # Response
    #  Name  Type
    #  item  Conversation

    def conversation(conversationId)
      url = "/conversations/#{conversationId}.json"

      begin
        item = Client.requestItem(@auth, url, nil)
        conversation = nil
        if item
          conversation = Conversation.new(item)
        end
      rescue StandardError => e
        print "Could not fetch conversation with id #{conversationId}: " + e.message
      end
    end


    # List Conversations
    # http://developer.helpscout.net/conversations/
    #
    # Fetches conversations in a mailbox with a given status
    #
    # mailboxId      Int       id of the Mailbox being requested
    # status         String    Filter by conversation status
    # limit          Int       This function will page through 
    #                          CollectionsEnvelopes until all items are 
    #                          returned, unless a limit is specified.
    # modifiedSince  DateTime  Returns conversations that have been modified 
    #                          since the given date/time.
    #
    # Possible values for status include:
    # * CONVERSATION_FILTER_STATUS_ALL      (Default)
    # * CONVERSATION_FILTER_STATUS_ACTIVE
    # * CONVERSATION_FILTER_STATUS_PENDING
    #
    # Request 
    #  REST Method: GET
    #  URL: https://api.helpscout.net/v1/mailboxes/{mailboxId}/conversations.json
    #
    #  Parameters:
    #   Name           Type      Required  Default  Notes
    #   page           Int       No        1 
    #   status         String    No        all      Active/Pending only applies 
    #                                               to the following folders: 
    #                                               Unassigned
    #                                               My Tickets
    #                                               Drafts
    #                                               Assigned
    #   modifiedSince  DateTime  No                 Returns conversations that 
    #                                               have been modified since the
    #                                               given date/time.
    #
    # Response
    #  Name   Type
    #  items  Array  Collection of Conversation objects. Conversation threads 
    #                are not returned on this call. To get the conversation 
    #                threads, you need to retrieve the full conversation object 
    #                via the Get Conversation call.

    CONVERSATION_FILTER_STATUS_ACTIVE = "active"
    CONVERSATION_FILTER_STATUS_ALL = "all"
    CONVERSATION_FILTER_STATUS_PENDING = "pending"

    def conversations(mailboxId, status, limit=0, modifiedSince)
      url = "/mailboxes/#{mailboxId}/conversations.json"

      page = 1
      options = {}

      if limit < 0
        limit = 0
      end

      if status && (status == CONVERSATION_FILTER_STATUS_ACTIVE || status == CONVERSATION_FILTER_STATUS_ALL || status == CONVERSATION_FILTER_STATUS_PENDING)
        options["status"] = status
      end

      if modifiedSince
        options["modifiedSince"] = modifiedSince
      end

      conversations = []

      begin
        options["page"] = page
        items = Client.requestItems(@auth, url, options)
        items.each do |item|
          conversations << Conversation.new(item)
        end
        page = page + 1
      rescue StandardError => e
        print "List Conversations Request failed: " + e.message
      end while items && items.count > 0 && (limit == 0 || conversations.count < limit)

      if limit > 0 && conversations.count > limit
        conversations = conversations[0..limit-1]
      end

      conversations
    end


    # List Conversations in Folder
    # http://developer.helpscout.net/conversations/
    #
    # Return conversations in a specific folder of a mailbox.
    #
    # mailboxId      Int       id of the Mailbox being requested
    # folderId       Int       id of the Folder being requested
    # status         String    Filter by conversation status
    # limit          Int       This function will page through 
    #                          CollectionsEnvelopes until all items are 
    #                          returned, unless a limit is specified.
    # modifiedSince  DateTime  Returns conversations that have been modified 
    #                          since the given date/time.
    #
    # Possible values for status include:
    # * CONVERSATION_FILTER_STATUS_ALL      (Default)
    # * CONVERSATION_FILTER_STATUS_ACTIVE
    # * CONVERSATION_FILTER_STATUS_PENDING
    #
    # Request 
    #  REST Method: GET
    #  URL: https://api.helpscout.net/v1/mailboxes/{mailboxId}/folders/{folderId}/conversations.json
    #
    #  Parameters:
    #   Name           Type      Required  Default  Notes
    #   page           Int       No        1 
    #   status         String    No        all      Active/Pending only applies 
    #                                               to the following folders: 
    #                                               Unassigned
    #                                               My Tickets
    #                                               Drafts
    #                                               Assigned
    #   modifiedSince  DateTime  No                 Returns conversations that 
    #                                               have been modified since the
    #                                               given date/time.
    #
    # Response
    #  Name   Type
    #  items  Array  Collection of Conversation objects. Conversation threads 
    #                are not returned on this call. To get the conversation 
    #                threads, you need to retrieve the full conversation object 
    #                via the Get Conversation call.

    def conversationsInFolder(mailboxId, folderId, status, limit=0, modifiedSince)
      url = "/mailboxes/#{mailboxId}/folders/#{folderId}/conversations.json"

      page = 1
      options = {}

      if limit < 0
        limit = 0
      end

      if status && (status == CONVERSATION_FILTER_STATUS_ACTIVE || status == CONVERSATION_FILTER_STATUS_ALL || status == CONVERSATION_FILTER_STATUS_PENDING)
        options["status"] = status
      end

      if modifiedSince
        options["modifiedSince"] = modifiedSince
      end

      conversations = []

      begin
        options["page"] = page
        items = Client.requestItems(@auth, url, options)
        items.each do |item|
          conversations << Conversation.new(item)
        end
        page = page + 1
      rescue StandardError => e
        print "List Conversations In Folder Request failed: " + e.message
      end while items && items.count > 0 && (limit == 0 || conversations.count < limit)

      if limit > 0 && conversations.count > limit
        conversations = conversations[0..limit-1]
      end

      conversations
    end


    # Conversation Count
    # http://developer.helpscout.net/conversations/
    #
    # Returns a count for conversations in a mailbox with a given status
    #
    # mailboxId      Int       id of the Mailbox being requested
    # status         String    Filter by conversation status
    # modifiedSince  DateTime  id of the Mailbox being requested
    #
    # Possible values for status include:
    # * CONVERSATION_FILTER_STATUS_ALL      (Default)
    # * CONVERSATION_FILTER_STATUS_ACTIVE
    # * CONVERSATION_FILTER_STATUS_PENDING
    #
    # Request 
    #  REST Method: GET
    #  URL: https://api.helpscout.net/v1/mailboxes/{mailboxId}/conversations.json
    #
    #  Parameters:
    #   Name           Type      Required  Default  Notes
    #   page           Int       No        1 
    #   status         String    No        all      Active/Pending only applies 
    #                                               to the following folders: 
    #                                               Unassigned
    #                                               My Tickets
    #                                               Drafts
    #                                               Assigned
    #   modifiedSince  DateTime  No                 Returns conversations that 
    #                                               have been modified since the
    #                                               given date/time.
    #
    # Response
    #  Name   Type
    #  count  Integer  Count of Conversation objects.

    def conversationCount(mailboxId, status, modifiedSince)
      url = "/mailboxes/#{mailboxId}/conversations.json"

      page = 1
      options = {}

      if status && (status == CONVERSATION_FILTER_STATUS_ACTIVE || status == CONVERSATION_FILTER_STATUS_ALL || status == CONVERSATION_FILTER_STATUS_PENDING)
        options["status"] = status
      end

      if modifiedSince
        options["modifiedSince"] = modifiedSince
      end

      conversations = []

      begin
        options["page"] = page
        count = Client.requestCount(@auth, url, options)
      rescue StandardError => e
        print "Conversation Count Request failed: " + e.message
      end
    end


    # Get Attachment Data
    # http://developer.helpscout.net/conversations/
    #
    # Fetches the AttachmentData from a given Attachment
    #
    # attachmentId  Int  id of the Attachment being requested
    #
    # Request 
    #  REST Method: GET
    #  URL: https://api.helpscout.net/v1/attachments/{id}/data.json
    #
    # Response
    #  Name  Type
    #  item  Conversation::AttachmentData

    def attachmentData(attachmentId)
      url = "/attachments/#{attachmentId}/data.json"
      item = Client.requestItem(@auth, url, nil)
      attachmentData = nil
      if item
        attachmentData = Conversation::AttachmentData.new(item)
      end

      attachmentData
    end


    # Get Customer
    # http://developer.helpscout.net/customers/
    #
    # Fetches a single Customer
    #
    # customerId  Int  id of the Customer being requested
    #
    # Request 
    #  REST Method: GET
    #  URL: https://api.helpscout.net/v1/customers/{id}.json
    #
    # Response
    #  Name  Type
    #  item  Customer

    def customer(customerId)
      url = "/customers/#{customerId}.json"
      item = Client.requestItem(@auth, url, nil)
      customer = nil
      if item
        customer = Customer.new(item)
      end

      customer
    end


    # List Customers
    # http://developer.helpscout.net/customers/
    #
    # Fetches all customers. Customers are returned by createdAt date, from 
    # newest to oldest.
    #
    # Request 
    #  REST Method: GET
    #  URL: https://api.helpscout.net/v1/customers.json
    #
    #  Parameters:
    #   Name           Type      Required  Default  Notes
    #   page           Int       No        1 
    #
    # Response
    #  Name   Type
    #  items  Array  Collection of Customer objects.

    def customers
      url = "/customers.json"
      items = Client.requestItems(@auth, url, :page => 1)
      customers = []
      items.each do |item|
        customers << Customer.new(item)
      end

      customers
    end
  end  
end
