require "rails_helper"

RSpec.describe "Api::V2::UsersController", type: :request do
  let(:user) { create(:user, :admin, :with_profile, apikey: "secret123") }
  let!(:profile) { user.profile }

  let(:headers) do
    {
      "CONTENT_TYPE" => "application/json",
      "ACCEPT" => "application/json"
    }
  end

  let(:base64_png) do
    Base64.strict_encode64(
      File.binread(Rails.root.join("spec/fixtures/files/trend.png"))
    )
  end

  describe "PATCH /api/v2/users/:id/update_profile" do
    context "when request is authorized with apikey" do
      it "updates profile fields" do
        patch "/api/v2/users/#{user.id}/update_profile",
              params: {
                apikey: user.apikey,
                "user/profile": {
                  code: "new-code",
                  record_mode: "default",
                  frames_per_second: 30
                }
              }.to_json,
              headers: headers

        expect(response).to have_http_status(:ok)

        profile.reload
        expect(profile.code).to eq("new-code")
        expect(profile.frames_per_second).to eq("30")
      end

      it "uploads trend through json base64" do
        patch "/api/v2/users/#{user.id}/update_profile",
              params: {
                apikey: user.apikey,
                "user/profile": {
                  trend_filename: "trend.png",
                  trend_content_type: "image/png",
                  trend_base64: base64_png
                }
              }.to_json,
              headers: headers

        expect(response).to have_http_status(:ok)

        profile.reload
        expect(profile.trend).to be_attached
        expect(profile.trend.filename.to_s).to eq("trend.png")
        expect(profile.trend.content_type).to eq("image/png")
      end

      it "returns unprocessable_entity for invalid base64" do
        patch "/api/v2/users/#{user.id}/update_profile",
              params: {
                apikey: user.apikey,
                "user/profile": {
                  trend_filename: "trend.png",
                  trend_content_type: "image/png",
                  trend_base64: "not-valid-base64!!!"
                }
              }.to_json,
              headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "rejects unsupported content type" do
        patch "/api/v2/users/#{user.id}/update_profile",
              params: {
                apikey: user.apikey,
                "user/profile": {
                  trend_filename: "trend.txt",
                  trend_content_type: "text/plain",
                  trend_base64: Base64.strict_encode64("hello")
                }
              }.to_json,
              headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when request is unauthorized" do
      it "returns unauthorized" do
        patch "/api/v2/users/#{user.id}/update_profile",
              params: {
                "user/profile": {
                  code: "new-code"
                }
              }.to_json,
              headers: headers

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
