require 'spec_helper'

describe "Ratings" do
  let(:helpscout) { HelpScout::Client.new("JUNKAPIKEY") }
  let(:json1) {
    HelpScout::CollectionsEnvelope.new(
      {
        "results" => [
          {
            "number" => 59504,
            "id" => 1545009,
            "type" => "email",
            "threadid" => 2952132,
            "threadCreatedAt" => "2015-01-14T15:09:39Z",
            "ratingId" => 2,
            "ratingCustomerId" => 449122,
            "ratingComments" => "",
            "ratingCreatedAt" => "2015-01-14T15:10:40Z",
            "ratingCustomerName" => "john@example.com",
            "ratingUserId" => 4,
            "ratingUserName" => "John Smith 1"
          }
        ]
      }).items
  }

  let(:json2) {
    HelpScout::CollectionsEnvelope.new(
      {
        "results" => [
          {
            "number" => 59504,
            "id" => 1545009,
            "type" => "email",
            "threadid" => 2952132,
            "threadCreatedAt" => "2015-01-14T15:09:39Z",
            "ratingId" => 1,
            "ratingCustomerId" => 449122,
            "ratingComments" => "",
            "ratingCreatedAt" => "2015-01-14T15:10:40Z",
            "ratingCustomerName" => "john@example.com",
            "ratingUserId" => 4,
            "ratingUserName" => "John Smith 2"
          }
        ]
      }).items
  }

  let(:empty_json) {
    HelpScout::CollectionsEnvelope.new({
      "results" => [

      ]
    }).items
  }

  it "should get list of items from helpscout pages" do
    expect(HelpScout::Client).to receive(:request_items).with({:username=>"JUNKAPIKEY", :password=>"X"}, "/reports/happiness/ratings.json", {"start"=>"2016-02-25T00:00:00Z", "end"=>"2016-02-29T00:00:00Z", "rating"=>0, "page"=> anything }).and_return(json1, json2, empty_json)
    ratings = helpscout.ratings('2016-02-25T00:00:00Z', '2016-02-29T00:00:00Z', 0)

    expect(ratings.count).to eq(2)
    expect(ratings.first.rating).to eq("Okay")
    expect(ratings[1].rating).to eq("Great")
  end
end
