require "date"
require "httparty"

class HelpScout
  include HTTParty
  base_uri 'https://api.helpscout.net/v1'

  def initialize(key)
    @auth = {:username => key, :password => ""}
    @users = []
    @mailboxes = []
  end

  def request(url, params={})
    items = []
    complete_url = url

    parameterString = ""
    params.each do |k,v|
      if parameterString.length > 0
        parameterString << "&"
      else
        parameterString << "?"
      end
      parameterString << "#{k}=#{v}"
    end

    if parameterString.length > 0
      complete_url << parameterString
    end

    response = self.class.get(complete_url, {:basic_auth => @auth})

    if response
      paginatedResponse = PaginatedResponse.new(response)
      if paginatedResponse.items
        paginatedResponse.items.each do |item|
          items << item
        end
      end

      if paginatedResponse.page < paginatedResponse.pages
        params[:page] = paginatedResponse.page + 1
        items << self.request(url, params)
      end
    end

    items
  end

  def users(options={})
    url = "/users.json"
    items = self.request(url, :page => 1)
    @users = []
    items.each do |item|
      @users << User.new(item)
    end
    @users
  end
  
  def mailboxes(options={})
    url = "/mailboxes.json"
    items = self.request(url, :page => 1)
    @mailboxes = []
    items.each do |item|
      @mailboxes << Mailbox.new(item)
    end
    @mailboxes
  end

  # :status String
  # :modifiedSince Datetime
  def conversations(mailboxId, options={})
    options.merge!({:page => 1})

    url = "/mailboxes/#{mailboxId}/conversations.json"
    items = self.request(url, options)
    conversations = []
    items.each do |item|
      conversations << Conversation.new(item)
    end
    conversations
  end

  def customers(options={})
    url = "/customers.json"
    items = self.request(url, :page => 1)
    customers = []
    items.each do |item|
      customers << Customer.new(item)
    end
    customers
  end


  class PaginatedResponse
    attr_accessor :page, :pages, :count, :items
    def initialize(object)
      @page = object["page"]
      @pages = object["pages"]
      @count = object["count"]
      @items = object["items"]
    end
  end

  class Mailbox
    attr_accessor :id, :name, :slug, :email, :createdAt, :modifiedAt
    def initialize(object)
      @id = object["id"]
      @name = object["name"]
      @slug = object["slug"]
      @email = object["email"]
      @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
      @modifiedAt = DateTime.iso8601(object["modifiedAt"]) if object["modifiedAt"]
    end
  end

  class Conversation
    attr_accessor :id, :folder, :isDraft, :number, :ownerId, :mailboxId, :customerId, :threadCount, :status, :subject, :preview, :createdBy, :createdAt, :modifiedAt, :closedAt, :closedBy, :source, :cc, :bcc, :tags

    def initialize(object)
      @id = object["id"]
      @folder = object["folder"]
      @isDraft = object["isDraft"]
      @number = object["number"]
      @ownerId = object["ownerId"]
      @mailboxId = object["mailboxId"]
      @customerId = object["customerId"]
      @threadCount = object["threadCount"]
      @status = object["status"]
      @subject = object["subject"]
      @preview = object["preview"]
      @createdBy = object["createdBy"]
      @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
      @modifiedAt = DateTime.iso8601(object["modifiedAt"]) if object["modifiedAt"]
      @closedAt = DateTime.iso8601(object["closedAt"]) if object["closedAt"]
      @closedBy = object["closedBy"]
      @source = object["source"]
      @cc = object["cc"]
      @bcc = object["bcc"]
      @tags = object["tags"]
    end

    def to_s
      "Assigned to user #{@ownerId}: #{@subject}\n#{@preview}\nLast update: #{@modifiedAt}\n\n"
    end
  end

  class User
    attr_accessor :id, :firstName, :lastName, :email, :role, :timezone, :photoUrl, :createdAt, :createdBy

    def initialize(object)
      @id = object["id"]
      @firstName = object["firstName"]
      @lastName = object["lastName"]
      @email = object["email"]
      @role = object["role"]
      @timezone = object["timezone"]
      @photoUrl = object["photoUrl"]
      @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
      @createdBy = object["createdBy"]
    end

    def to_s
      "#{@firstName} #{@lastName}"
    end
  end

  class Customer
    attr_accessor :id, :firstName, :lastName, :photoUrl, :photoType, :gender, :age, :organization, :jobTitle, :location, :createdAt, :modifiedAt

    def initialize(object)
      @id = object["id"]
      @firstName = object["firstName"]
      @lastName = object["lastName"]
      @photoUrl = object["photoUrl"]
      @photoType = object["photoType"]
      @gender = object["gender"]
      @age = object["age"]
      @organization = object["organization"]
      @jobTitle = object["jobTitle"]
      @location = object["location"]
      @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
      @modifiedAt = DateTime.iso8601(object["modifiedAt"]) if object["modifiedAt"]
    end

    def to_s
      "#{@firstName} #{@lastName}"
    end
  end
end

