module Api
  module V2
    class UsersController < ApiController
      respond_to :json

      def profile
        user = resource_scope.find(params[:id])
        authorize user
        profile = user.profile

        render json: profile, serializer: ProfileSerializer, status: :ok
      end

      def update_profile
        user = resource_scope.find(params[:id])
        authorize(user)
        profile = user.profile

        ActiveRecord::Base.transaction do
          unless profile.update(update_params)
            raise ActiveRecord::Rollback
          end

          attach_trend!(profile) if trend_upload_present?
        end

        if profile.errors.empty?
          render json: profile, serializer: ProfileSerializer, status: :ok
        else
          render json: { errors: profile.errors.full_messages }, status: :unprocessable_entity
        end
      rescue ArgumentError => e
        render json: { errors: [e.message] }, status: :unprocessable_entity
      end

      private

      def resource_scope
        policy_scope([:api, :v2, User])
      end

      def update_params
        params.require('user/profile').permit(
          :code,
          :display_time,
          :record_mode,
          :voice_control,
          :frames_per_second
        )
      end

      def trend_upload_present?
        profile_params[:trend_base64].present?
      end

      def profile_params
        params.require('user/profile').permit(
          :code,
          :display_time,
          :record_mode,
          :voice_control,
          :frames_per_second,
          :trend_base64,
          :trend_filename,
          :trend_content_type
        )
      end

      def attach_trend!(profile)
        base64_data = profile_params[:trend_base64]
        filename = profile_params[:trend_filename].presence || "trend"
        content_type = profile_params[:trend_content_type].presence || "application/octet-stream"

        decoded = decode_base64_file(base64_data)

        profile.trend.attach(
          io: StringIO.new(decoded),
          filename: filename,
          content_type: content_type
        )
      end

      def decode_base64_file(data)
        if data.include?("base64,")
          data = data.split("base64,", 2).last
        end

        Base64.strict_decode64(data)
      rescue ArgumentError
        raise ArgumentError, "Invalid Base64 file data"
      end

      def authorize(record, query = nil)
        super([:api, :v2, record], query)
      end
    end
  end
end
