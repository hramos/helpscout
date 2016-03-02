module HelpScout

  # Rating List
  #
  # Response	Name	Type	Notes
  # Header	Status	Int	200
  # Body	pages	Int	The total number of pages
  # page	Int	The current page
  # count	Int	Total number of ratings
  # results	Collection	Collection of details about each rating for a given user for a given time range
  # results[index].number	Int	The conversation number
  # results[index].id	Int	The unique conversation identifier
  # results[index].type	String	The type of conversation; valid values include:
  # email
  # chat
  # phone
  # results[index].threadid	Int	Unique identifier for the thread associated with this rating
  # results[index].threadCreatedAt	Date/Time	ISO 8601, in UTC
  # results[index].ratingId	Int	Unique identifier of the rating
  # results[index].ratingCustomerId	Int	Unique identifer of the customer who submitted this rating
  # results[index].ratingComments	String	Comments the customer submitted (if any)
  # results[index].ratingCreatedAt	Date/Time	ISO 8601, in UTC
  # results[index].ratingCustomerName	String	Name of the customer who submitted this rating
  # results[index].ratingUserId	Int	Unique identifer of the usesr associated with this rating
  # results[index].ratingUserName	String	Name of the user associated with this rating

  class Rating
    attr_reader :number, :id, :type, :threadid, :threadCreatedAt, :ratingId, :rating, :ratingCustomerId, :ratingComments, :ratingCreatedAt, :ratingCustomerName, :ratingUserId, :ratingUserName

    RATING_TYPES = {
      1 => "Great",
      2 => "Okay",
      3 => "Not Good"
    }

    # Creates a new Rating object
    def initialize(object)
      @createdAt = DateTime.iso8601(object["createdAt"]) if object["createdAt"]
      @modifiedAt = DateTime.iso8601(object["modifiedAt"]) if object["modifiedAt"]

      @number = object["number"] #The conversation number
      @id = object["id"] #conversation_id
      @type = object["type"]
      @threadid = object["threadid"]
      @threadCreatedAt = object["threadCreatedAt"]
      @ratingId = object["ratingId"] #level of rating described as "Unique identifier of the rating"???
      @rating = object["rating"] || lookup_rating(@ratingId)
      @ratingCustomerId = object["ratingCustomerId"]
      @ratingComments = object["ratingComments"]
      @ratingCreatedAt = object["ratingCreatedAt"]
      @ratingCustomerName = object["ratingCustomerName"]
      @ratingUserId = object["ratingUserId"]
      @ratingUserName = object["ratingUserName"]
    end

    private

    def lookup_rating rating_id
      RATING_TYPES[rating_id]
    end
  end
end
