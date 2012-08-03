require "date"
require "httparty"

module HelpScout
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

    class Folder
      attr_accessor :id, :name, :type, :userId, :totalCount, :activeCount, :modifiedAt
  
      def initialize(object)
        @id = object["id"]
        @name = object["name"]
        @type = object["type"]
        @userId = object["userId"]
        @totalCount = object["totalCount"]
        @activeCount = object["activeCount"]
        @modifiedAt = DateTime.iso8601(object["modifiedAt"]) if object["modifiedAt"]
      end
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

    class Attachment
      attr_accessor :id, :mimeType, :filename, :size, :width, :height, :url

      def initialize(object)
        @id = object["id"]
        @mimeType = object["mimeType"]
        @filename = object["filename"]
        @size = object["size"]
        @width = object["width"]
        @height = object["height"]
        @url = object["url"]
      end
    end

    class AttachmentData
      attr_accessor :id, :data

      def initialize(object)
        @id = object["id"]
        @data = object["data"]
      end
    end

    class Source
      attr_accessor :type, :via

      def initialize(object)
        @type = object["type"] # email, web, notification, emailfwd
        @via = object["via"] # customer, user
      end
    end

    class Thread
      attr_accessor :id, :assignedTo, :status, :createdAt, :createdBy, :source, :fromMailboxId, :type, :state, :customerId, :body, :to, :cc, :bcc, :attachments

      def initialize(object)
        @id = object["id"]
        @assignedTo = object["assignedTo"]
        @status = object["status"]
        @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
        @createdBy = object["createdBy"]

        @source = nil
        if object["source"]
          @source = Source.new(object["source"])
        end

        @fromMailboxId = object["fromMailboxId"]
        @type = object["type"]
        @state = object["state"]
        @customerId = object["customerId"]
        @body = object["body"]
        @to = object["to"]
        @cc = object["cc"]
        @bcc = object["bcc"]

        @attachments = []
        if object["attachments"]
          object["attachments"].each do |item|
            @attachments << Attachment.new(item)
          end
        end

      end
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
    attr_accessor :id, :firstName, :lastName, :photoUrl, :photoType, :gender, :age, :organization, :jobTitle, :location, :createdAt, :modifiedAt, :background, :address, :socialProfiles, :emails, :phones, :chats, :websites

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
      @background = object["background"]

      @address = nil
      if object["address"]
        @address = Address.new(object["address"])
      end

      @socialProfiles = []
      if object["socialProfiles"]
        object["socialProfiles"].each do |item|
          @socialProfiles << SocialProfile.new(item)
        end
      end

      @emails = []
      if object["emails"]
        object["emails"].each do |item|
          @emails << Email.new(item)
        end
      end

      @phones = []
      if object["phones"]
        object["phones"].each do |item|
          @phones << Phone.new(item)
        end
      end

      @chats = []
      if object["chats"]
        object["chats"].each do |item|
          @chats << Chat.new(item)
        end
      end

      @websites = []
      if object["websites"]
        object["websites"].each do |item|
          @websites << Website.new(item)
        end
      end

      @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
      @modifiedAt = DateTime.iso8601(object["modifiedAt"]) if object["modifiedAt"]
    end

    def to_s
      "#{@firstName} #{@lastName}"
    end

    class Address
      attr_accessor :id, :lines, :city, :state, :postalCode, :country, :createdAt, :modifiedAt
      def initialize(object)
        @id = object["id"]
        @lines = object["lines"]
        @city = object["city"]
        @state = object["state"]
        @postalCode = object["postalCode"]
        @country = object["country"]
        @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
        @modifiedAt = DateTime.iso8601(object["modifiedAt"]) if object["modifiedAt"]
      end
    end

    class Chat
      attr_accessor :id, :value, :type
      def initialize(object)
        @id = object["id"]
        @value = object["value"]
        @type = object["type"]
      end
    end

    class Email
      attr_accessor :id, :value, :location
      def initialize(object)
        @id = object["id"]
        @value = object["value"]
        @location = object["location"] # work*, home, other
      end
    end

    class Phone
      attr_accessor :id, :value, :location
      def initialize(object)
        @id = object["id"]
        @value = object["value"]
        @location = object["location"] # home, work, mobile, fax, pager, other
      end
    end

    class SocialProfile
      attr_accessor :id, :value, :type
      def initialize(object)
        @id = object["id"]
        @value = object["value"]
        @type = object["type"] # twitter, facebook, linkedin, aboutme, google, googleplus, tungleme, quora, foursquare, youtube, flickr, other
      end
    end

    class Website
      attr_accessor :id, :value
      def initialize(object)
        @id = object["id"]
        @value = object["value"]
      end
    end
  end
end

