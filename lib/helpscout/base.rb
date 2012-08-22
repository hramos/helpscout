require "date"
require "uri"
require "httparty"
require "helpscout/models"
require "erb"

module HelpScout
  class Base
    include HTTParty
    base_uri 'https://api.helpscout.net/v1'

    def initialize(key=nil)
      Base.settings

      if key.nil?
        key = @@settings["api_key"]
      end

      @auth = { :username => key, :password => "X" }
      @users = []
      @mailboxes = []
    end

    @@settings ||= nil

    def self.load!(api_key)
      @auth = { :username => api_key, :password => "X" }
      @users = []
      @mailboxes = []
      @@settings = {"api_key" => api_key}
    end

    def self.settings
      if @@settings.nil?
        path = "config/helpscout.yml"
        @@settings = YAML.load(ERB.new(File.new(path).read).result)
        @auth = { :username => @@settings["api_key"], :password => "X" }
      end
      @@settings
    end

    def self.parametrizedUrl(url, params={})
      return url unless params

      uri = URI(url)
      parameterString = ""

      params.each do |k,v|
        if parameterString.length > 0
          parameterString << "&"
        end
        parameterString << "#{k}=#{v}"
      end

      if parameterString.length > 0
        uri.query = parameterString
      end

      uri.to_s
    end

    def self.requestItem(url, params={})
      item = nil
      complete_url = Base.parametrizedUrl(url, params)

      response = Base.get(complete_url, {:basic_auth => @auth})

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

    def self.requestItems(url, params={})
      items = []
      complete_url = Base.parametrizedUrl(url, params)

      response = Base.get(complete_url, {:basic_auth => @auth})

      if 200 <= response.code && response.code < 300
        envelope = CollectionsEnvelope.new(response)
        if envelope.items
          envelope.items.each do |item|
            items << item
          end
        end

        if envelope.page < envelope.pages
          params[:page] = envelope.page + 1
          items = items + Base.requestItems(url, params)
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
    
    def self.user(userId)
      url = "/users/#{userId}.json"
      item = Base.requestItem(url, nil)
      user = nil
      if item
        user = User.new(item)
      end
      user
    end

    def self.users
      url = "/users.json"
      items = Base.requestItems(url, :page => 1)
      @users = []
      items.each do |item|
        @users << User.new(item)
      end
      @users
    end

    def self.usersInMailbox(mailboxId)
      url ="/mailboxes/#{mailboxId}/users.json"
      items = Base.requestItems(url, :page => 1)
      users = []
      items.each do |item|
        users << User.new(item)
      end
      users
    end

    def self.mailboxes
      url = "/mailboxes.json"
      @mailboxes = []
      begin
        items = Base.requestItems(url, {})
        items.each do |item|
          @mailboxes << Mailbox.new(item)
        end
      rescue StandardError => e
        print "Request failed: " + e.message
      end
      @mailboxes
    end

    def self.foldersInMailbox(mailboxId)
      url ="/mailboxes/#{mailboxId}/folders.json"
      items = Base.requestItems(url, :page => 1)
      folders = []
      items.each do |item|
        folders << Mailbox::Folder.new(item)
      end
      folders
    end

    def self.conversation(conversationId)
      url = "/conversations/#{conversationId}.json"
      item = Base.requestItem(url, nil)
      conversation = nil
      if item
        conversation = Conversation.new(item)
      end
      conversation
    end


    CONVERSATION_STATUS_ACTIVE = "active"
    CONVERSATION_STATUS_ALL = "all"
    CONVERSATION_STATUS_PENDING = "pending"

    def self.conversations(mailboxId, status, modifiedSince)
      url = "/mailboxes/#{mailboxId}/conversations.json"

      options = {}
      if status
        options["status"] = status
      end
      if modifiedSince
        # TODO: Check modifiedSince format. Needs to be Datetime in UTC
        options["modifiedSince"] = modifiedSince
      end

      conversations = []
      begin
        items = Base.requestItems(url, options)
        items.each do |item|
          conversations << Conversation.new(item)
        end
      rescue StandardError => e
        print "Request failed: " + e.message
      end
      conversations
    end

    def self.customer(customerId)
      url = "/customers/#{customerId}.json"
      item = Base.requestItem(url, nil)
      customer = nil
      if item
        customer = Customer.new(item)
      end
      customer
    end

    def self.customers
      url = "/customers.json"
      items = Base.requestItems(url, :page => 1)
      customers = []
      items.each do |item|
        customers << Customer.new(item)
      end
      customers
    end

    def self.attachmentData(attachmentId)
      url = "/attachments/#{attachmentId}/data.json"
      item = Base.requestItem(url, nil)
      attachmentData = nil
      if item
        attachmentData = Conversation::AttachmentData.new(item)
      end
      attachmentData
    end
  end

  # TODO: check response, if 200, it's one of the first two.
  # If 403, error
  class SingleItemEnvelope
    attr_accessor :item
    def initialize(object)
      @item = object["item"]
    end
  end

  class CollectionsEnvelope
    attr_accessor :page, :pages, :count, :items
    def initialize(object)
      @page = object["page"]
      @pages = object["pages"]
      @count = object["count"]
      @items = object["items"]
    end
  end

  class ErrorEnvelope
    attr_accessor :status, :message
    def initialize(object)
      @status = object["status"]
      @message = object["message"]
    end    
  end
end