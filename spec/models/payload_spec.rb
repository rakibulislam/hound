require "fast_spec_helper"
require "attr_extras"
require "app/models/payload"

describe Payload do
  describe '#changed_files' do
    context "with pull_request data" do
      it "returns number of changed files" do
        fixture_file = "spec/support/fixtures/pull_request_opened_event.json"
        payload_json = File.read(fixture_file)
        payload = Payload.new(payload_json)

        expect(payload.changed_files).to eq 1
      end
    end

    context "with no pull_request data" do
      it "returns zero" do
        data = "{}"
        payload = Payload.new(data)

        expect(payload.changed_files).to be_zero
      end
    end
  end

  describe "#head_sha" do
    context "with pull_request data" do
      it "returns sha" do
        data = { "pull_request" => { "head" => { "sha" => "abc123" } } }
        payload = Payload.new(data)

        expect(payload.head_sha).to eq "abc123"
      end
    end

    context "with no pull_request data" do
      it "returns nil" do
        payload = Payload.new("some_key" => "something")

        expect(payload.head_sha).to be_nil
      end
    end
  end

  describe '#data' do
    it 'returns data' do
      data = {one: 1}
      payload = Payload.new(data)

      expect(payload.data).to eq data
    end
  end

  describe "#pull_request_number" do
    it "returns the pull request number" do
      data = { "number" => 2 }
      payload = Payload.new(data)

      expect(payload.pull_request_number).to eq 2
    end
  end

  describe "#repository_owner_name" do
    it "returns the owner of the repo's name" do
      data = {
        "repository" => {
          "owner" => {
            "login" => "thoughtbot"
          }
        }
      }

      payload = Payload.new(data)

      expect(payload.repository_owner_name).to eq "thoughtbot"
    end
  end

  describe "#repository_owner_id" do
    it "returns the owner of the repo's ID" do
      data = {
        "repository" => {
          "owner" => {
            "id" => 1
          }
        }
      }

      payload = Payload.new(data)

      expect(payload.repository_owner_id).to eq 1
    end
  end

  describe "#repository_owner_is_organization?" do
    context "when the repository owner is a user" do
      it "returns false" do
        payload_json = {
          "repository" => {
            "owner" => {
              "id" => 1,
              "type" => "User"
            }
          }
        }
        payload = Payload.new(payload_json)

        expect(payload.repository_owner_is_organization?).to be false
      end
    end

    context "when the repository owner is an organization" do
      it "returns true" do
        payload_json = {
          "repository" => {
            "owner" => {
              "id" => 1,
              "type" => "Organization"
            }
          }
        }
        payload = Payload.new(payload_json)

        expect(payload.repository_owner_is_organization?).to be true
      end
    end
  end
end
