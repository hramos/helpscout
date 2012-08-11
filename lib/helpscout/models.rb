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
  
      FOLDER_TYPE_UNASSIGNED = "unassigned"
      FOLDER_TYPE_MY_TICKETS = "mytickets"
      FOLDER_TYPE_DRAFTS = "drafts"
      FOLDER_TYPE_ASSIGNED = "assigned"
      FOLDER_TYPE_CLOSED = "closed"
      FOLDER_TYPE_SPAM = "spam"

      def initialize(object)
        @id = object["id"]
        @name = object["name"]
        @type = object["type"]
        @userId = object["userId"] # 0, unless type == FOLDER_TYPE_MY_TICKETS
        @totalCount = object["totalCount"]
        @activeCount = object["activeCount"]
        @modifiedAt = DateTime.iso8601(object["modifiedAt"]) if object["modifiedAt"]
      end
    end
  end

  class Conversation
    attr_accessor :id, :folderId, :isDraft, :number, :owner, :mailbox, :customer, :threadCount, :status, :subject, :preview, :createdBy, :createdAt, :modifiedAt, :closedAt, :closedBy, :source, :cc, :bcc, :tags, :threads

    CONVERSATION_STATUS_ACTIVE = "active"
    CONVERSATION_STATUS_PENDING = "pending"
    CONVERSATION_STATUS_CLOSED = "closed"
    CONVERSATION_STATUS_SPAM = "spam"

    def initialize(object)
      @id = object["id"]
      @folderId = object["folderId"]
      @isDraft = object["isDraft"]
      @number = object["number"]
      @owner = User.new(object["owner"]) if object["owner"]
      @mailbox = Mailbox.new(object["mailbox"]) if object["mailbox"]
      @customer = Customer.new(object["customer"]) if object["customer"]
      @threadCount = object["threadCount"]
      @status = object["status"]
      @subject = object["subject"]
      @preview = object["preview"]
      @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
      @modifiedAt = DateTime.iso8601(object["modifiedAt"]) if object["modifiedAt"]
      @closedAt = DateTime.iso8601(object["closedAt"]) if object["closedAt"]
      @closedBy = User.new(object["closedBy"]) if object["closedBy"]

      @source = nil
      if object["source"]
        @source = Source.new(object["source"])

        if object["createdBy"]
          if @source.type == Source::SOURCE_VIA_CUSTOMER
            @createdBy = Customer.new(object["createdBy"])
          elsif @source.type == Source::SOURCE_VIA_USER
            @createdBy = User.new(object["createdBy"])
          end
        end
      end

      @cc = object["cc"]
      @bcc = object["bcc"]
      @tags = object["tags"]

      @threads = []
      if object["threads"]
        object["threads"].each do |thread|
          @threads << Thread.new(thread)
        end
      end
    end

    def to_s
      "Last Modified: #{@modifiedAt}\nAssigned to: #{@owner}\nSubject: #{@subject}\n#{@preview}"
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

      SOURCE_TYPE_EMAIL = "email"
      SOURCE_TYPE_WEB = "web"
      SOURCE_TYPE_NOTIFICATION = "notification"
      SOURCE_TYPE_EMAIL_FWD = "emailfwd"

      SOURCE_VIA_USER = "user"
      SOURCE_VIA_CUSTOMER = "customer"

      def initialize(object)
        @type = object["type"]
        @via = object["via"]
      end
    end

    class Thread
      attr_accessor :id, :assignedTo, :status, :createdAt, :createdBy, :source, :fromMailbox, :type, :state, :customer, :body, :to, :cc, :bcc, :attachments

      THREAD_STATE_PUBLISHED = "published"
      THREAD_STATE_DRAFT = "draft"
      THREAD_STATE_UNDER_REVIEW = "underreview"

      THREAD_STATUS_ACTIVE = "active"
      THREAD_STATUS_NO_CHANGE = "nochange"
      THREAD_STATUS_PENDING = "pending"
      THREAD_STATUS_CLOSED = "closed"
      THREAD_STATUS_SPAM = "spam"

      THREAD_TYPE_NOTE = "note"
      THREAD_TYPE_MESSAGE = "message"
      THREAD_TYPE_CUSTOMER = "customer"

      # A lineitem represents a change of state on the conversation. This could include, but not limited to, the conversation was assigned, the status changed, the conversation was moved from one mailbox to another, etc. A line item won't have a body, to/cc/bcc lists, or attachments.
      THREAD_TYPE_LINEITEM = "lineitem" 

      # When a conversation is forwarded, a new conversation is created to represent the forwarded conversation.
      THREAD_TYPE_FWD_PARENT = "forwardparent" # forwardparent is the type set on the thread of the original conversation that initiated the forward event.
      THREAD_TYPE_FWD_CHILD = "forwardchild" # forwardchild is the type set on the first thread of the new forwarded conversation.

      
      def initialize(object)
        @id = object["id"]
        @assignedTo = User.new(object["assignedTo"]) if object["assignedTo"]
        @status = object["status"]
        @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]

        @source = nil
        if object["source"]
          @source = Source.new(object["source"])

          if object["createdBy"]
            if @source.type == Source::SOURCE_VIA_CUSTOMER
              @createdBy = Customer.new(object["createdBy"])
            elsif @source.type == Source::SOURCE_VIA_USER
              @createdBy = User.new(object["createdBy"])
            end
          end
        end

        @fromMailbox = Mailbox.new(object["fromMailbox"]) if object["fromMailbox"]
        @type = object["type"]
        @state = object["state"]
        @customer = Customer.new(object["customer"]) if object["customer"]
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

      def to_s
        "#{@customer}: #{@body}"
      end
    end

  end

  class User
    attr_accessor :id, :firstName, :lastName, :email, :role, :timezone, :photoUrl, :createdAt, :createdBy

    USER_ROLE_OWNER = "owner"
    USER_ROLE_ADMIN = "admin"
    USER_ROLE_USER = "user"

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

    CUSTOMER_PHOTO_TYPE_UNKNOWN = "unknown"
    CUSTOMER_PHOTO_TYPE_GRAVATAR = "gravatar"
    CUSTOMER_PHOTO_TYPE_TWITTER = "twitter"
    CUSTOMER_PHOTO_TYPE_FACEBOOK = "facebook"
    CUSTOMER_PHOTO_TYPE_GOOGLE_PROFILE = "googleprofile"
    CUSTOMER_PHOTO_TYPE_GOOGLE_PLUS = "googleplus"
    CUSTOMER_PHOTO_TYPE_LINKEDIN = "linkedin"

    CUSTOMER_GENDER_MALE = "male"
    CUSTOMER_GENDER_FEMALE = "female"
    CUSTOMER_GENDER_UNKNOWN = "unknown"

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

      CHAT_TYPE_AIM = "aim"
      CHAT_TYPE_GTALK = "gtalk"
      CHAT_TYPE_ICQ = "icq"
      CHAT_TYPE_XMPP = "xmpp"
      CHAT_TYPE_MSN = "msn"
      CHAT_TYPE_SKYPE = "skype"
      CHAT_TYPE_YAHOO = "yahoo"
      CHAT_TYPE_QQ = "qq"
      CHAT_TYPE_OTHER = "other"

      def initialize(object)
        @id = object["id"]
        @value = object["value"]
        @type = object["type"]
      end
    end

    class Email
      attr_accessor :id, :value, :location

      EMAIL_LOCATION_WORK = "work"
      EMAIL_LOCATION_HOME = "home"
      EMAIL_LOCATION_OTHER = "other"

      def initialize(object)
        @id = object["id"]
        @value = object["value"]
        @location = object["location"]
      end
    end

    class Phone
      attr_accessor :id, :value, :location

      PHONE_LOCATION_HOME = "home"
      PHONE_LOCATION_WORK = "work"
      PHONE_LOCATION_MOBILE = "mobile"
      PHONE_LOCATION_FAX = "fax"
      PHONE_LOCATION_PAGER = "pager"
      PHONE_LOCATION_OTHER = "other"

      def initialize(object)
        @id = object["id"]
        @value = object["value"]
        @location = object["location"]
      end
    end

    class SocialProfile
      attr_accessor :id, :value, :type

      SOCIAL_PROFILE_TYPE_TWITTER = "twitter"
      SOCIAL_PROFILE_TYPE_FACEBOOK = "facebook"
      SOCIAL_PROFILE_TYPE_LINKEDIN = "linkedin"
      SOCIAL_PROFILE_TYPE_ABOUTME = "aboutme"
      SOCIAL_PROFILE_TYPE_GOOGLE = "google"
      SOCIAL_PROFILE_TYPE_GOOGLE_PLUS = "googleplus"
      SOCIAL_PROFILE_TYPE_TUNGLEME = "tungleme"
      SOCIAL_PROFILE_TYPE_QUORA = "quora"
      SOCIAL_PROFILE_TYPE_FOURSQUARE = "foursquare"
      SOCIAL_PROFILE_TYPE_YOUTUBE = "youtube"
      SOCIAL_PROFILE_TYPE_FLICKR = "flickr"
      SOCIAL_PROFILE_TYPE_OTHER = "other"

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

