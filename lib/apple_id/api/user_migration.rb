module AppleID
  module API
    module UserMigration
      def transfer_from!(transfer_sub:)
        resource_request do
          post(
            user_migration_endpoint,
            transfer_sub:  transfer_sub,
            client_id:     client.identifier,
            client_secret: client.secret
          )
        end
      end

      def transfer_to!(sub:, target:)
        resource_request do
          post(
            user_migration_endpoint,
            sub:           sub,
            target:        client.team_id,
            client_id:     client.identifier,
            client_secret: client.secret
          )
        end
      end

      private

      def user_migration_endpoint
        File.join(ISSUER, '/auth/usermigrationinfo')
      end
    end

    AccessToken.include UserMigration
  end
end