module Api
  module V2
    module Users
      class ProfilesController < ApiController
        before_action :set_profile

        def show
          authorize(@profile)
          render json: @profile, serializer: ProfileSerializer, status: :ok
        end

        def update
          authorize(@profile)

          if @profile.update(update_params)
            render json: @profile, serializer: ProfileSerializer, status: :ok
          else
            render json: { errors: @profile.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def presence
          authorize(@profile)
          current_api_user.update_column(:last_seen_at, DateTime.current)
          head :ok
        end

        private

        def set_profile
          @profile = current_api_user.profile || current_api_user.create_profile!
        end

        def update_params
          params.require(:profile).permit(:code)
        end
      end
    end
  end
end
