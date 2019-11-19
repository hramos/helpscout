module HelpScout
  class SingleItemEnvelope
    attr_reader :item

    def initialize(object)
      @item = object
    end
  end

  class CollectionsEnvelope
    attr_reader :page, :pages, :count, :items

    def initialize(object)
      @page = object["page"]['number']
      @pages = object["page"]['totalPages']
      @count = object["page"]["totalElements"]
      @items = object["_embedded"].values.first
    end
  end

  class ErrorEnvelope
    attr_reader :status, :message

    def initialize(object)
      @status = object.code
      @message = object["message"]
    end
  end

  class Mailbox
    attr_reader :id, :name, :slug, :email, :createdAt, :modifiedAt, :folders

    def initialize(object)
      @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
      @modifiedAt = DateTime.iso8601(object["updatedAt"]) if object["updatedAt"]
      @id = object["id"]
      @name = object["name"]
      @slug = object["slug"]
      @email = object["email"]
      @folders = []
    end
  end

  class Customer
    attr_reader :firstName, :lastName, :age, :background, :gender, :id, :photoType, :location, :organization, :jobTitle, :createdAt, :modifiedAt, :photoUrl, :emails, :phones, :websites

    def initialize(object)
      @firstName = object["firstName"]
      @lastName = object["lastName"]
      @age = object["age"]
      @background = object["background"]
      @gender = object["gender"]
      @id = object["id"]
      @photoType = object["photoType"]
      @location = object["location"]
      @organization = object["organization"]
      @jobTitle = object["jobTitle"]
      @photoUrl = object["photoUrl"]

      @createdAt =  DateTime.iso8601(object["createdAt"]) if object["createdAt"]
      @modifiedAt = DateTime.iso8601(object["updatedAt"]) if object["updatedAt"]

      @emails = []
      if object["emails"]
        object["emails"].each { |item| @emails << Email.new(item) }
      elsif object["_embedded"] && object["_embedded"]["emails"]
        object["_embedded"] && object["_embedded"]["emails"].each { |item| @emails << Email.new(item) }
      end

      @phones = []
      if object["phones"]
        object["phones"].each { |item| @phones << Phone.new(item) }
      elsif object["_embedded"] && object["_embedded"]["phones"]
        object["_embedded"] && object["_embedded"]["phones"].each { |item| @phones << Phone.new(item) }
      end

      @websites = []
      if object["websites"]
        object["websites"].each { |item| @websites << Website.new(item) }
      elsif object["_embedded"] && object["_embedded"]["websites"]
        object["_embedded"] && object["_embedded"]["websites"].each { |item| @websites << Website.new(item) }
      end
    end

    def to_s
      "#{@firstName} #{@lastName}"
    end

    class Email
      attr_reader :type, :value, :id

      def initialize(object)
        @id = object["id"]
        @type = object["type"]
        @value = object["value"]
      end
    end

    class Phone
      attr_reader :type, :value, :id

      def initialize(object)
        @id = object["id"]
        @type = object["type"]
        @value = object["value"]
      end
    end

    class Website
      attr_reader :value, :id

      def initialize(object)
        @id = object["id"]
        @value = object["value"]
      end
    end
  end

  class Conversation
    attr_reader :id, :bcc, :cc, :folderId, :type, :tags, :subject, :mailboxId, :customer, :status, :assignTo, :assignee, :modifiedAt, :preview, :threads, :source, :number

    def initialize(object)
      @id = object["id"]
      @bcc = object["bcc"]
      @cc = object["cc"]
      @folderId = object["folderId"]
      @type = object["type"]
      @tags = object["tags"]
      @subject = object["subject"]
      @mailboxId = object["mailboxId"]
      @customer =
        if object["primaryCustomer"]
          Person.new(object["primaryCustomer"])
        elsif object["customer"]
          object["customer"]
        end
      @status = object["status"]
      @assignTo = object["assignTo"]
      @assignee = Person.new(object["assignee"]) if object["assignee"]

      if object.has_key?("userUpdatedAt")
        @modifiedAt = DateTime.iso8601(object["userUpdatedAt"])
      elsif object.has_key?("updatedAt")
        @modifiedAt = DateTime.iso8601(object["updatedAt"])
      end
      @preview = object["preview"]
      @source = Source.new(object["source"]) if object["source"]
      @number = object["number"]

      @threads = []
      if object["_embedded"] && object["_embedded"]["threads"]
        object["_embedded"]["threads"].each { |item| @threads << Thread.new(item) }
      elsif object["threads"]
        object["threads"] && object["threads"].each { |item| @threads << Thread.new(item) }
      end
    end

    def owner
      assignee
    end

    def change_array
      [
        { "op": "replace", "path": "/status", "value": status },
        { "op": "replace", "path": "/assignTo", "value": assignTo },
        { "op": "replace", "path": "/subject", "value": subject }
      ]
    end

    def to_s
      "Last Modified: #{@modifiedAt}\nStatus: #{@status}\nAssigned to: #{@assignee}\nSubject: #{@subject}\n#{@preview}"
    end

    class Thread
      attr_reader :id, :assignedTo, :status, :createdAt, :createdBy, :type, :state, :customer, :text, :to, :cc, :bcc, :attachments, :openedAt, :body, :source, :action

      def initialize(object)
        @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
        @openedAt = DateTime.iso8601(object["openedAt"]) if object["openedAt"]
        @id = object["id"]
        @assignedTo = Person.new(object["assignedTo"]) if object["assignedTo"]
        @createdBy = Person.new(object["createdBy"]) if object["createdBy"]
        @status = object["status"]
        @type = object["type"]
        @state = object["state"]
        @customer = Person.new(object["customer"]) if object["customer"]
        @text = object["text"]
        @to = object["to"]
        @cc = object["cc"]
        @bcc = object["bcc"]
        @body = object["body"]
        @source = Source.new(object["source"]) if object["source"]
        @action = Action.new(object["action"]) if object["action"]

        @attachments = []
        if object["attachments"]
          object["attachments"].each { |item| @attachments << item }
        elsif object["_embedded"] && object["_embedded"]["attachments"]
          object["_embedded"]["attachments"].each { |item| @attachments << Attachment.new(item) }
        end
      end

      # Returns a String suitable for display
      def to_s
        "#{@customer}: #{@body}"
      end

      def actionType
        action.try(:type)
      end

      def actionSourceId
        action.try(:associatedEntities).try(:values).try(:first)
      end
    end

    class Attachment
      attr_reader :id, :mimeType, :filename, :size, :width, :height, :url

      def initialize(object)
        @id = object["id"]
        @mimeType = object["mimeType"]
        @filename = object["filename"]
        @size = object["size"]
        @width = object["width"]
        @height = object["height"]
        @url = object["_links"]["data"]["href"] if object["_links"] && object["_links"]["data"]
      end
    end

    class AttachmentData
      attr_reader :id, :data

      def initialize(object)
        @id = object["id"]
        @data = object["data"]
      end
    end
  end

  class Action
    attr_reader :type, :text, :associatedEntities

    def initialize(object)
      @type = object["type"]
      @text = object["text"]
      @associatedEntities = object["associatedEntities"]
    end
  end

  class Person
    attr_reader :id, :firstName, :lastName, :email, :type

    def initialize(object)
      @id = object["id"]
      @firstName = object["first"]
      @lastName = object["last"]
      @email = object["email"]
      @type = object["type"]
    end

    def to_s
      "#{@firstName} #{@lastName}"
    end
  end

  class Source
    attr_reader :type, :via

    TYPE_EMAIL = "email"
    TYPE_WEB = "web"
    TYPE_NOTIFICATION = "notification"
    TYPE_FWD = "emailfwd"

    VIA_USER = "user"
    VIA_CUSTOMER = "customer"

    def initialize(object)
      @type = object["type"]
      @via = object["via"]
    end
  end

  class AuthToken
    attr_reader :token, :expires_at

    def initialize(object)
      @token = object['access_token']
      @expires_at = Time.now.utc + (object['expires_in'].to_i - 100) # -100 just to be sure we don't use expired token
    end

    def expired?
      expires_at <= Time.now.utc
    end
  end
end
