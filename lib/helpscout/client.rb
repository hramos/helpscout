require "erb"
require "httparty"
require "yaml"
require "base64"

module HelpScout
  class Client
    include HTTParty

    base_uri 'https://api.helpscout.net/v2'
    format :json

    class << self
      attr_reader :auth_token

      def request_item(auth, url, params = {})
        ensure_authorized!(auth)

        item = nil

        request_url = ""
        request_url << url
        if params
          query = ""
          params.each { |k, v| query += "#{k}=#{v}&" }
          request_url << "?" + query
        end

        begin
          response = Client.get(request_url, headers: auth_headers)
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

      def request_items(auth, url, params = {})
        ensure_authorized!(auth)

        items = []

        request_url = ""
        request_url << url
        if params
          query = ""
          params.each { |k,v| query += "#{k}=#{v}&" }
          request_url << "?" + query
        end

        begin
          response = Client.get(request_url, headers: auth_headers)
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

      def create_item(auth, url, params = {})
        ensure_authorized!(auth)

        begin
          response = Client.post(url, headers: { 'Content-Type' => 'application/json;charset=UTF-8' }.merge(auth_headers), body: params)
        rescue SocketError => se
          raise StandardError, se.message
        end

        if response.code == 201
          if response["item"]
            response["item"]
          else
            response.headers["location"]
          end
        else
          raise StandardError.new("Server Response: #{response.code} #{response['message']}")
        end
      end

      def update_item(auth, url, params = {})
        ensure_authorized!(auth)

        begin
          response = Client.put(url, headers: { 'Content-Type' => 'application/json;charset=UTF-8' }.merge(auth_headers), body: params)
        rescue SocketError => se
          raise StandardError, se.message
        end

        if response.code == 204
          true
        else
          raise StandardError.new("Server Response: #{response.code} #{response['message']}")
        end
      end

      def change_item(auth, url, params = {})
        ensure_authorized!(auth)

        begin
          response = Client.patch(url, headers: { 'Content-Type' => 'application/json;charset=UTF-8' }.merge(auth_headers), body: params)
        rescue SocketError => se
          raise StandardError, se.message
        end

        if response.code == 204
          true
        else
          raise StandardError.new("Server Response: #{response.code} #{response['message']}")
        end
      end

      private

      def ensure_authorized!(auth)
        return if auth_token.present? && !auth_token.expired?
        @auth_token = request_auth_token(auth)
      end

      def request_auth_token(auth)
        params = { grant_type: 'client_credentials', client_id: auth[:app_id], client_secret: auth[:app_secret] }

        begin
          response = Client.post('/oauth2/token', body: params)
        rescue SocketError => se
          raise StandardError, se.message
        end

        if response.code == 200
          AuthToken.new(response)
        else
          raise StandardError.new("Server Response: #{response.code} #{response.message}")
        end
      end

      def auth_headers
        { 'Authorization' => "Bearer #{auth_token.token}" }
      end
    end

    def initialize(app_id, app_secret)
      @auth = { app_id: app_id, app_secret: app_secret }
    end

    def mailboxes
      url = "/mailboxes"
      mailboxes = []

      items = Client.request_items(@auth, url, {})
      items.each do |item|
        mailboxes << Mailbox.new(item)
      end

      mailboxes
    end

    def conversation(conversationId)
      url = "/conversations/#{conversationId}?embed=threads"

      item = Client.request_item(@auth, url, nil)
      conversation = nil
      if item
        conversation = Conversation.new(item)
      end
    end

    def create_conversation(conversation)
      if !conversation
        raise StandardError.new("Missing Conversation")
      end

      url = "/conversations"

      Client.create_item(@auth, url, conversation.to_json)
    end

    def update_conversation(conversation)
      if !conversation || !conversation.id
        raise StandardError.new("Missing Conversation")
      end

      url = "/conversations/#{conversation.id}"

      Client.change_item(@auth, url, conversation.to_change_json)
    end

    def create_conversation_thread(conversationId, thread)
      url = "/conversations/#{conversationId}/#{thread.type}s"

      Client.create_item(@auth, url, thread.to_json)
    end

    CONVERSATION_FILTER_STATUS_ACTIVE = "active"
    CONVERSATION_FILTER_STATUS_ALL = "all"
    CONVERSATION_FILTER_STATUS_PENDING = "pending"

    def conversations(mailboxId, status, limit=0, modifiedSince)
      url = "/conversations"

      page = 1
      options = { 'mailbox' => mailboxId, 'embed': 'threads' }

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
        items = Client.request_items(@auth, url, options)
        items.each do |item|
          conversations << Conversation.new(item)
        end
        page = page + 1
      end while items && items.count > 0 && (limit == 0 || conversations.count < limit)

      if limit > 0 && conversations.count > limit
        conversations = conversations[0..limit-1]
      end

      conversations
    end

    def customer(customerId)
      url = "/customers/#{customerId}"
      item = Client.request_item(@auth, url, nil)
      customer = nil
      if item
        customer = Customer.new(item)
      end

      customer
    end

    def create_customer(customer)
      if !customer
        raise StandardError.new("Missing Customer")
      end

      url = "/customers"

      Client.create_item(@auth, url, customer.to_json)
    end

    def update_customer(customer)
      if !customer || !customer.id
        raise StandardError.new("Missing Customer")
      end

      url = "/customers/#{customer.id}"

      Client.update_item(@auth, url, customer.to_json)
    end

    def attachment_data(url)
      item = Client.request_item(@auth, url, nil)
      attachmentData = nil
      if item
        attachmentData = Conversation::AttachmentData.new(item)
      end

      attachmentData
    end
  end
end
