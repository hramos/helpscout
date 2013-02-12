# Help Scout API V1 Client
# http://developer.helpscout.net/
#
# These models are used by the HelpScout client.
#
# They include wrappers for the three response envelopes, as well as wrappers
# for the JSON hashes returned in SingleItemEnvelope and CollectionsEnvelope.
#
# All date/times returned by the API are in ISO8601 format and in UTC timezone.

module HelpScout

  # Response Envelopes
  # http://developer.helpscout.net/
  #
  # The Help Scout API will return one of three envelopes, depending upon the 
  # request issued.
  
  # Single Item Envelope
  class SingleItemEnvelope
    attr_reader :item

    # Creates a new SingleItemEnvelope object from a Hash of attributes
    def initialize(object)
      @item = object["item"]
    end
  end

  # Collections Envelope
  class CollectionsEnvelope
    attr_reader :page, :pages, :count, :items
    
    # Creates a new CollectionsEnvelope object from a Hash of attributes
    def initialize(object)
      @page = object["page"]
      @pages = object["pages"]
      @count = object["count"]
      @items = object["items"]
    end
  end

  # Error Envelope
  class ErrorEnvelope
    attr_reader :status, :message

    # Creates a new ErrorEnvelope object from a Hash of attributes
    def initialize(object)
      @status = object["status"]
      @message = object["message"]
    end    
  end


  # Client Objects

  # Mailbox
  # http://developer.helpscout.net/objects/mailbox/
  # http://developer.helpscout.net/objects/mailbox/mailbox-ref/
  #
  # MailboxRefs are a subset of a full Mailbox object, and only include the 
  # attributes marked with a *.
  #
  # MailboxRefs are returned by endpoints that include multiple mailboxes.
  # A full Mailbox object can be obtained by fetching a single mailbox directly.
  #
  #  Name       Type      Example               Notes
  # *id         Int       1234                  Unique identifier
  # *name       String    Feedback              Name of the Mailbox
  #  slug       String    47204a026903ce6d      Key used to represent this 
  #                                             Mailbox
  #  email      String    feedback@parse.com    Email address
  #  createdAt  DateTime  2012-07-23T12:34:12Z  UTC time when this mailbox was 
  #                                             created.
  #  modifiedAt DateTime  2012-07-24T20:18:33Z  UTC time when this mailbox was 
  #                                             modified.

  class Mailbox
    attr_reader :id, :name, :slug, :email, :createdAt, :modifiedAt, :folders

    # Creates a new Mailbox object from a Hash of attributes
    def initialize(object)
      @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
      @modifiedAt = DateTime.iso8601(object["modifiedAt"]) if object["modifiedAt"]

      @id = object["id"]
      @name = object["name"]
      
      @slug = object["slug"]
      @email = object["email"]

      @folders = []
      if object["folders"]
        object["folders"].each do |folder|
          @folders << Folder.new(folder)
        end
      end      
    end
  end


  # Conversation
  # http://developer.helpscout.net/objects/conversation/
  #
  #  Name         Type        Example               Notes
  #  id           Int         2391938111            Unique identifier
  #  folderId     Int         1234                  ID of the Folder to which 
  #                                                 this conversation resides.
  #  isDraft      Boolean     false                 Is this a draft?
  #  number       Int         349                   The conversation number 
  #                                                 displayed in the UI.
  #  owner        Person                            User of the Help Scout user 
  #                                                 that is currently assigned 
  #                                                 to this conversation
  #  mailbox      Mailbox                           Mailbox to which this 
  #                                                 conversation belongs.
  #  customer     Person                            Customer to which this 
  #                                                 conversation belongs.
  #  threadCount  Int         4                     This count represents the 
  #                                                 number of published threads 
  #                                                 found on the conversation 
  #                                                 (it does not include line 
  #                                                 items, drafts or threads 
  #                                                 held for review by Traffic 
  #                                                 Cop).
  #  status       String      active                Status of the conversation.
  #  subject      String      I need help!   
  #  preview      String      Hello, I...   
  #  createdBy    Person                            Either the Customer or User 
  #                                                 that created this 
  #                                                 conversation. 
  #                                                 Inspect the Source object 
  #                                                 for clarification.
  #  createdAt    DateTime    2012-07-23T12:34:12Z  UTC time when this 
  #                                                 conversation was created.
  #  modifiedAt   DateTime    2012-07-24T20:18:33Z  UTC time when this.
  #                                                 conversation was modified.
  #  closedAt     DateTime                          UTC time when this 
  #                                                 conversation was closed.
  #                                                 Null if not closed.
  #  closedBy     Person                            User of the Help Scout user 
  #                                                 that closed this 
  #                                                 conversation.
  #  source       Source                            Specifies the method in 
  #                                                 which this conversation was 
  #                                                 created.
  #  cc           Array                             Collection of strings 
  #                                                 representing emails.
  #  bcc          Array                             Collection of strings
  #                                                 representing emails.
  #  tags         Array                             Collection of strings
  #  threads      Array                             Collection of Thread 
  #                                                 objects. Only available when
  #                                                 retrieving a single 
  #                                                 Conversation
  #
  # Possible values for status include:
  # * STATUS_ACTIVE
  # * STATUS_PENDING
  # * STATUS_CLOSED
  # * STATUS_SPAM

  class Conversation
    attr_reader :id, :type, :folderId, :isDraft, :number, :owner, :mailbox, :customer, :threadCount, :status, :subject, :preview, :createdBy, :createdAt, :modifiedAt, :closedAt, :closedBy, :source, :cc, :bcc, :tags, :threads, :url

    STATUS_ACTIVE = "active"
    STATUS_PENDING = "pending"
    STATUS_CLOSED = "closed"
    STATUS_SPAM = "spam"

    # Creates a new Conversation object from a Hash of attributes
    def initialize(object)
      @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
      @modifiedAt = DateTime.iso8601(object["userModifiedAt"]) if object["userModifiedAt"]
      @closedAt = DateTime.iso8601(object["closedAt"]) if object["closedAt"]

      @id = object["id"]
      @type = object["type"]
      @folderId = object["folderId"]
      @isDraft = object["isDraft"]
      @number = object["number"]
      @owner = Person.new(object["owner"]) if object["owner"]
      @mailbox = Mailbox.new(object["mailbox"]) if object["mailbox"]
      @customer = Person.new(object["customer"]) if object["customer"]
      @threadCount = object["threadCount"]
      @status = object["status"]
      @subject = object["subject"]
      @preview = object["preview"]
      @closedBy = Person.new(object["closedBy"]) if object["closedBy"]
      @createdBy = Person.new(object["person"]) if object["person"]
      @source = Source.new(object["source"]) if object["source"]
      @cc = object["cc"]
      @bcc = object["bcc"]
      @tags = object["tags"]

      @threads = []
      if object["threads"]
        object["threads"].each do |thread|
          @threads << Thread.new(thread)
        end
      end

      @url = "https://secure.helpscout.net/conversation/#{@id}/#{@number}/"
    end

    # Returns a String suitable for display
    def to_s
      "Last Modified: #{@modifiedAt}\nStatus: #{@status}\nAssigned to: #{@owner}\nSubject: #{@subject}\n#{@preview}"
    end


    # Conversation::Thread
    # http://developer.helpscout.net/objects/conversation/thread/
    #
    #  Name         Type      Example               Notes
    #  id           Int       88171881              Unique identifier
    #  assignedTo   Person                          User of the Help Scout user 
    #                                               to which this conversation 
    #                                               has been assigned.
    #  status       String    active                Status of the thread. Thread
    #                                               status is only updated when 
    #                                               there is a status change. 
    #                                               Otherwise, the status will 
    #                                               be set to STATUS_NO_CHANGE.
    #  createdAt    DateTime  2012-07-23T12:34:12Z  UTC time when this thread 
    #                                               was created.
    #  createdBy    Person                          Either the Customer or User 
    #                                               that created this 
    #                                               conversation. Inspect the 
    #                                               Source object for 
    #                                               clarification.
    #  source       Source     
    #  fromMailbox  Mailbox                         If the conversation was 
    #                                               moved, fromMailbox 
    #                                               represents the Mailbox from 
    #                                               which it was moved.
    #  type         String    message               The type of thread. 
    #  state        String    published             The state of the thread. 
    #  customer     Person                          If type is message, this is 
    #                                               the Customer of the customer
    #                                               in which the message was 
    #                                               sent. If type is customer, 
    #                                               this is the Customer of the 
    #                                               customer that initiated the 
    #                                               thread.
    #  body         String    Thank you.   
    #  to           Array                           Collection of Strings 
    #                                               representing emails.
    #  cc           Array                           Collection of Strings
    #                                               representing emails.
    #  bcc          Array                           Collection of Strings
    #                                               representing emails.
    #  attachments  Array                           Collection of Attachment 
    #                                               objects, if they exist.
    #
    # Possible values for state include:
    # * STATE_PUBLISHED
    # * STATE_DRAFT
    # * STATE_UNDER_REVIEW
    #
    # A state of STATE_UNDER_REVIEW means the thread has been stopped by Traffic
    # Cop and is waiting to be confirmed (or discarded) by the person that 
    # created the thread.
    #
    # Traffic Cop is the Help Scout feature that stops a thread from going out 
    # if multiple Users act on the same Help Scout simultaneously.
    #
    # Possible values for status include:
    # * STATUS_ACTIVE
    # * STATUS_NO_CHANGE
    # * STATUS_PENDING
    # * STATUS_CLOSED
    # * STATUS_SPAM
    #
    # Possible values for type include:
    # * TYPE_NOTE
    # * TYPE_MESSAGE
    # * TYPE_CUSTOMER
    # * TYPE_LINEITEM
    # * TYPE_FWD_PARENT
    # * TYPE_FWD_CHILD
    #
    # TYPE_LINEITEM represents a change of state on the conversation. This could
    # include, but not limited to, the conversation was assigned, the status 
    # changed, the conversation was moved from one mailbox to another, etc. A 
    # line item won't have a body, to/cc/bcc lists, or attachments.
    #
    # When a conversation is forwarded, a new conversation is created to 
    # represent the forwarded conversation.
    # * TYPE_FWD_PARENT is the type set on the thread of the original 
    #   conversation that initiated the forward event.
    # * TYPE_FWD_CHILD is the type set on the first thread of the new forwarded 
    #   conversation.

    class Thread
      attr_reader :id, :assignedTo, :status, :createdAt, :createdBy, :source, :fromMailbox, :type, :state, :customer, :body, :to, :cc, :bcc, :attachments

      STATE_PUBLISHED = "published"
      STATE_DRAFT = "draft"
      STATE_UNDER_REVIEW = "underreview"

      STATUS_ACTIVE = "active"
      STATUS_NO_CHANGE = "nochange"
      STATUS_PENDING = "pending"
      STATUS_CLOSED = "closed"
      STATUS_SPAM = "spam"

      TYPE_NOTE = "note"
      TYPE_MESSAGE = "message"
      TYPE_CUSTOMER = "customer"
      TYPE_LINEITEM = "lineitem" 
      TYPE_FWD_PARENT = "forwardparent"
      TYPE_FWD_CHILD = "forwardchild"
    
      # Creates a new Conversation::Thread object from a Hash of attributes
      def initialize(object)
        @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]

        @id = object["id"]
        @assignedTo = Person.new(object["assignedTo"]) if object["assignedTo"]
        @createdBy = Person.new(object["createdBy"]) if object["createdBy"]
        @status = object["status"]
        @source = Source.new(object["source"]) if object["source"]
        @fromMailbox = Mailbox.new(object["fromMailbox"]) if object["fromMailbox"]
        @type = object["type"]
        @state = object["state"]
        @customer = Person.new(object["customer"]) if object["customer"]
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

      # Returns a String suitable for display
      def to_s
        "#{@customer}: #{@body}"
      end
    end


    # Conversation::Attachment
    # http://developer.helpscout.net/objects/conversation/attachment/
    # 
    #  Name      Type    Example               Notes
    #  id        Int     12391                 Unique identifier
    #  mimeType  String  image/jpeg   
    #  filename  String  logo.jpg   
    #  size      Int     22                    Size of the attachment in bytes.
    #  width     Int     160  
    #  height    Int     160  
    #  url       String  https://.../logo.jpg  Public-facing url where 
    #                    attachment can be downloaded

    class Attachment
      attr_reader :id, :mimeType, :filename, :size, :width, :height, :url

      # Creates a new Conversation::Attachment object from a Hash of attributes
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


    # Conversation::AttachmentData
    # http://developer.helpscout.net/objects/conversation/attachment-data/
    #
    #  Name  Type    Example  Notes
    #  id    Int     887171   Unique identifier
    #  data  String           base64 encoded data

    class AttachmentData
      attr_reader :id, :data

      # Creates a new Conversation::AttachmentData object from a Hash of 
      # attributes
      def initialize(object)
        @id = object["id"]
        @data = object["data"]
      end
    end
  end


  # Person
  # http://developer.helpscout.net/objects/person/
  #
  # The person object is a subset of the data representing a Customer or 
  # User. The 'type' property will specify if this person is represented by 
  # a 'user' or a 'customer'.
  # 
  #  Name        Type      Example                 Notes
  #  id          Int       1234                    Unique identifier
  #  firstName   String    Jack   
  #  lastName    String    Sprout   
  #  email       String    jack.sprout@gmail.com  
  #  phone       String    800-555-1212  
  #  type        String    user 
  #
  # Possible values for type include:
  # * TYPE_USER
  # * TYPE_CUSTOMER

  class Person
    attr_reader :id, :firstName, :lastName, :email, :phone, :type

    TYPE_USER = "user"
    TYPE_CUSTOMER = "customer"

    # Creates a new Person object from a Hash of attributes
    def initialize(object)
      @id = object["id"]
      @firstName = object["firstName"]
      @lastName = object["lastName"]
      @email = object["email"]
      @phone = object["phone"]
      @type = object["type"]
    end

    # Returns a String suitable for display
    def to_s
      "#{@firstName} #{@lastName}"
    end
  end


  # User
  # http://developer.helpscout.net/objects/user/
  #
  #  Name        Type      Example                 Notes
  #  id          Int       1234                    Unique identifier
  #  firstName   String    Jack   
  #  lastName    String    Sprout   
  #  email       String    jack.sprout@gmail.com  
  #  role        String    owner                   Role of this user.
  #  timezone    String    America/New_York   
  #  photoUrl    String    http://.../avatar.jpg   The user's photo, if one 
  #                                                exists.
  #  createdAt   DateTime  2011-04-01T03:18:33Z    UTC time when this user was 
  #                                                created.
  #  modifiedAt  DateTime  2012-07-24T20:18:33Z    UTC time when this user was 
  #                                                modified.
  #
  # Possible values for role include:
  # * ROLE_OWNER
  # * ROLE_ADMIN
  # * ROLE_USER

  class User
    attr_reader :id, :firstName, :lastName, :email, :role, :timezone, :photoUrl, :createdAt, :modifiedAt

    ROLE_OWNER = "owner"
    ROLE_ADMIN = "admin"
    ROLE_USER = "user"

    # Creates a new User object from a Hash of attributes
    def initialize(object)
      @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
      @modifiedAt = DateTime.iso8601(object["modifiedAt"]) if object["modifiedAt"]

      @id = object["id"]
      @firstName = object["firstName"]
      @lastName = object["lastName"]
      @email = object["email"]
      @role = object["role"]
      @timezone = object["timezone"]
      @photoUrl = object["photoUrl"]
    end

    # Returns a String suitable for display
    def to_s
      "#{@firstName} #{@lastName}"
    end
  end

  # Customer
  # http://developer.helpscout.net/objects/customer/
  #
  # Attributes marked with a * are returned when listing customers. Other
  # attributes are only returned when fetching a single customer.
  #
  #  Name          Type      Example               Notes
  # *id            Int       29418                 Unique identifier
  # *firstName     String    Vernon   
  # *lastName      String    Bear   
  # *email         String    vbear@mywork.com      If the customer has multiple 
  #                                                emails, only one is returned.
  # *photoUrl      String    http://../avatar.jpg   
  # *photoType     String    twitter               Type of photo.
  # *gender        String    Male                  Gender of this customer.
  # *age           String    30-35  
  # *organization  String    Acme, Inc  
  # *jobTitle      String    CEO and Co-Founder   
  # *location      String    Austin
  # *createdAt     DateTime  2012-07-23T12:34:12Z  UTC time when this customer 
  #                                                was created.
  # *modifiedAt    DateTime  2012-07-24T20:18:33Z  UTC time when this customer 
  #                                                was modified.
  #  background      String   I've worked with...  This is the Background Info 
  #                                                field from the UI.
  #  address         Address
  #  socialProfiles  Array                         Array of SocialProfiles    
  #  emails          Array                         Array of Emails
  #  phones          Array                         Array of Phones
  #  chats           Array                         Array of Chats
  #  websites        Array                         Array of Websites
  #
  # Possible values for photoType include:
  # * PHOTO_TYPE_UNKNOWN
  # * PHOTO_TYPE_GRAVATAR
  # * PHOTO_TYPE_TWITTER
  # * PHOTO_TYPE_FACEBOOK
  # * PHOTO_TYPE_GOOGLE_PROFILE
  # * PHOTO_TYPE_GOOGLE_PLUS
  # * PHOTO_TYPE_LINKEDIN
  #
  # Possible values for gender include: 
  # * GENDER_MALE
  # * GENDER_FEMALE
  # * GENDER_UNKNOWN

  class Customer
    attr_reader :id, :firstName, :lastName, :photoUrl, :photoType, :gender, :age, :organization, :jobTitle, :location, :createdAt, :modifiedAt, :background, :address, :socialProfiles, :emails, :phones, :chats, :websites

    PHOTO_TYPE_UNKNOWN = "unknown"
    PHOTO_TYPE_GRAVATAR = "gravatar"
    PHOTO_TYPE_TWITTER = "twitter"
    PHOTO_TYPE_FACEBOOK = "facebook"
    PHOTO_TYPE_GOOGLE_PROFILE = "googleprofile"
    PHOTO_TYPE_GOOGLE_PLUS = "googleplus"
    PHOTO_TYPE_LINKEDIN = "linkedin"

    GENDER_MALE = "male"
    GENDER_FEMALE = "female"
    GENDER_UNKNOWN = "unknown"

    # Creates a new Customer object from a Hash of attributes
    def initialize(object)
      @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
      @modifiedAt = DateTime.iso8601(object["modifiedAt"]) if object["modifiedAt"]

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
    end

    # Returns a String suitable for display
    def to_s
      "#{@firstName} #{@lastName}"
    end


    # Customer::Address
    # http://developer.helpscout.net/objects/customer/address/
    #
    #  Name        Type            Example               Notes
    #  id          Int             1234                  Unique identifier
    #  lines       Array                                 Collection of strings 
    #                                                    representing the 
    #                                                    customer's street 
    #                                                    address.
    #  city        String          Dallas   
    #  state       String          TX   
    #  postalCode  String          74206  
    #  country     String          US   
    #  createdAt   DateTime        2012-07-23T12:34:12Z  UTC time when this 
    #                                                    address was created.
    #  modifiedAt  DateTime        2012-07-24T20:18:33Z  UTC time when this 
    #                                                    address was modified.

    class Address
      attr_reader :id, :lines, :city, :state, :postalCode, :country, :createdAt, :modifiedAt
      
      # Creates a new Address object from a Hash of attributes
      def initialize(object)
        @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
        @modifiedAt = DateTime.iso8601(object["modifiedAt"]) if object["modifiedAt"]
  
        @id = object["id"]
        @lines = object["lines"]
        @city = object["city"]
        @state = object["state"]
        @postalCode = object["postalCode"]
        @country = object["country"]
      end
    end


    # Customer::Chat
    # http://developer.helpscout.net/objects/customer/chat/
    #
    #  Name   Type    Example  Notes
    #  id     Int     77183    Unique identifier
    #  value  String  jsprout  
    #  type   String  aim      Chat type
    #
    # Possible values for type include:
    # * TYPE_AIM
    # * TYPE_GTALK
    # * TYPE_ICQ
    # * TYPE_XMPP
    # * TYPE_MSN
    # * TYPE_SKYPE
    # * TYPE_YAHOO
    # * TYPE_QQ
    # * TYPE_OTHER

    class Chat
      attr_reader :id, :value, :type

      TYPE_AIM = "aim"
      TYPE_GTALK = "gtalk"
      TYPE_ICQ = "icq"
      TYPE_XMPP = "xmpp"
      TYPE_MSN = "msn"
      TYPE_SKYPE = "skype"
      TYPE_YAHOO = "yahoo"
      TYPE_QQ = "qq"
      TYPE_OTHER = "other"

      # Creates a new Customer::Chat object from a Hash of attributes
      def initialize(object)
        @id = object["id"]
        @value = object["value"]
        @type = object["type"]
      end
    end


    # Customer::Email
    # http://developer.helpscout.net/objects/customer/email/
    #
    #  Name      Type    Example           Notes
    #  id        Int     98131             Unique identifier
    #  value     String  vbear@mywork.com   
    #  location  String  work              Location for this email address. 
    #                                      Defaults to LOCATION_WORK
    #
    # Possible values for location include:
    # * LOCATION_WORK (Default)
    # * LOCATION_HOME
    # * LOCATION_OTHER

    class Email
      attr_reader :id, :value, :location

      LOCATION_WORK = "work"
      LOCATION_HOME = "home"
      LOCATION_OTHER = "other"

      # Creates a new Customer::Email object from a Hash of attributes
      def initialize(object)
        @id = object["id"]
        @value = object["value"]
        @location = object["location"]
      end
    end


    # Customer::Phone
    # http://developer.helpscout.net/objects/customer/phone/
    #
    #  Name      Type    Example       Notes
    #  id        Int     22381         Unique identifier
    #  value     String  222-333-4444   
    #  location  String  home          Location for this phone
    #
    # Possible values for location include:
    # * LOCATION_HOME
    # * LOCATION_WORK
    # * LOCATION_MOBILE
    # * LOCATION_FAX
    # * LOCATION_PAGER
    # * LOCATION_OTHER

    class Phone
      attr_reader :id, :value, :location

      LOCATION_HOME = "home"
      LOCATION_WORK = "work"
      LOCATION_MOBILE = "mobile"
      LOCATION_FAX = "fax"
      LOCATION_PAGER = "pager"
      LOCATION_OTHER = "other"

      # Creates a new Customer::Phone object from a Hash of attributes
      def initialize(object)
        @id = object["id"]
        @value = object["value"]
        @location = object["location"]
      end
    end


    # Customer::SocialProfile
    # http://developer.helpscout.net/objects/customer/social-profile/
    #
    #  Name  Type    Example                        Notes
    #  id    Int     9184                           Unique identifier
    #  value String  https://twitter.com/helpscout  
    #  type  String  twitter                        Type of social profile.
    #
    # Possible values for type include:
    # * TYPE_TWITTER
    # * TYPE_FACEBOOK
    # * TYPE_LINKEDIN
    # * TYPE_ABOUTME
    # * TYPE_GOOGLE
    # * TYPE_GOOGLE_PLUS
    # * TYPE_TUNGLEME
    # * TYPE_QUORA
    # * TYPE_FOURSQUARE
    # * TYPE_YOUTUBE
    # * TYPE_FLICKR
    # * TYPE_OTHER

    class SocialProfile
      attr_reader :id, :value, :type

      TYPE_TWITTER = "twitter"
      TYPE_FACEBOOK = "facebook"
      TYPE_LINKEDIN = "linkedin"
      TYPE_ABOUTME = "aboutme"
      TYPE_GOOGLE = "google"
      TYPE_GOOGLE_PLUS = "googleplus"
      TYPE_TUNGLEME = "tungleme"
      TYPE_QUORA = "quora"
      TYPE_FOURSQUARE = "foursquare"
      TYPE_YOUTUBE = "youtube"
      TYPE_FLICKR = "flickr"
      TYPE_OTHER = "other"

      # Creates a new Customer::SocialProfile object from a Hash of attributes
      def initialize(object)
        @id = object["id"]
        @value = object["value"]
        @type = object["type"]
      end
    end


    # Customer::Website
    # http://developer.helpscout.net/objects/customer/website/
    #
    #  Name   Type    Example                   Notes
    #  id     Int     5584                      Unique identifier
    #  value  String  http://www.somewhere.com   

    class Website
      attr_reader :id, :value

      # Creates a new Customer::Website object from a Hash of attributes
      def initialize(object)
        @id = object["id"]
        @value = object["value"]
      end
    end
  end


  # Source
  # http://developer.helpscout.net/objects/source/
  #
  #  Name  Type    Example   Notes
  #  type  String  email     The method from which this conversation (or thread) 
  #                          was created.
  #  via   String  customer
  #
  # Possible values for type include:
  # * TYPE_EMAIL
  # * TYPE_WEB
  # * TYPE_NOTIFICATION
  # * TYPE_FWD
  # 
  # Possible values for via include:
  # * VIA_USER
  # * VIA_CUSTOMER

  class Source
    attr_reader :type, :via

    TYPE_EMAIL = "email"
    TYPE_WEB = "web"
    TYPE_NOTIFICATION = "notification"
    TYPE_FWD = "emailfwd"

    VIA_USER = "user"
    VIA_CUSTOMER = "customer"

    # Creates a new Source object from a Hash of attributes
    def initialize(object)
      @type = object["type"]
      @via = object["via"]
    end
  end


  # Folder
  # http://developer.helpscout.net/objects/folder/
  #
  #  Name         Type      Example               Notes
  #  id           Int       1234                  Unique identifier
  #  name         String    My Tickets            Folder name
  #  type         String    mytickets             The type this folder 
  #                                               represents.
  #  userId       Int       4532                  If the folder type is 
  #                                               TYPE_MY_TICKETS, userId 
  #                                               represents the Help Scout user
  #                                               to which this folder belongs. 
  #                                               Otherwise userId is 0.
  #  totalCount   Int       2                     Total number of conversations 
  #                                               in this folder
  #  activeCount  Int       1                     Total number of conversations 
  #                                               in this folder that are in an 
  #                                               active state (vs pending).
  #  modifiedAt   DateTime  2012-07-24T20:18:33Z  UTC time when this folder was 
  #                                               modified.
  #
  # Possible values for type include:
  # * TYPE_UNASSIGNED
  # * TYPE_MY_TICKETS
  # * TYPE_DRAFTS
  # * TYPE_ASSIGNED
  # * TYPE_CLOSED
  # * TYPE_SPAM

  class Folder
    attr_reader :id, :name, :type, :userId, :totalCount, :activeCount, :modifiedAt

    TYPE_UNASSIGNED = "open"
    TYPE_MY_TICKETS = "mytickets"
    TYPE_DRAFTS = "drafts"
    TYPE_ASSIGNED = "assigned"
    TYPE_CLOSED = "closed"
    TYPE_SPAM = "spam"

    # Creates a new Folder object from a Hash of attributes
    def initialize(object)
      @modifiedAt = DateTime.iso8601(object["modifiedAt"]) if object["modifiedAt"]

      @id = object["id"]
      @name = object["name"]
      @type = object["type"]
      @userId = object["userId"]
      @totalCount = object["totalCount"]
      @activeCount = object["activeCount"]
    end
  end
end
