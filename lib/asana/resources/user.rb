require_relative 'gen/users_base'

module Asana
  module Resources
    # A _user_ object represents an account in Asana that can be given access to
    # various workspaces, projects, and tasks.
    #
    # Like other objects in the system, users are referred to by numerical IDs.
    # However, the special string identifier `me` can be used anywhere
    # a user ID is accepted, to refer to the current authenticated user.
    class User < UsersBase


      attr_reader :gid

      attr_reader :resource_type

      attr_reader :name

      attr_reader :email

      attr_reader :photo

      attr_reader :workspaces

      class << self
        # Returns the plural name of the resource.
        def plural_name
          'users'
        end

        # Returns the full user record for the currently authenticated user.
        #
        # options - [Hash] the request I/O options.
        def me(client, options: {})

          Resource.new(parse(client.get("/users/me", options: options)).first, client: client)
        end

        # Returns the full user record for the single user with the provided ID.
        #
        # id - [String] An identifier for the user. Can be one of an email address,
        # the globally unique identifier for the user, or the keyword `me`
        # to indicate the current user making the request.
        #
        # options - [Hash] the request I/O options.
        def find_by_id(client, id, options: {})

          self.new(parse(client.get("/users/#{id}", options: options)).first, client: client)
        end

        # Returns the user records for all users in the specified workspace or
        # organization.
        #
        # workspace - [Id] The workspace in which to get users.
        # per_page - [Integer] the number of records to fetch per page.
        # options - [Hash] the request I/O options.
        def find_by_workspace(client, workspace: required("workspace"), per_page: 20, options: {})
          params = { limit: per_page }.reject { |_,v| v.nil? || Array(v).empty? }
          Collection.new(parse(client.get("/workspaces/#{workspace}/users", params: params, options: options)), type: self, client: client)
        end

        # Returns the user records for all users in all workspaces and organizations
        # accessible to the authenticated user. Accepts an optional workspace ID
        # parameter.
        #
        # workspace - [Id] The workspace or organization to filter users on.
        # per_page - [Integer] the number of records to fetch per page.
        # options - [Hash] the request I/O options.
        def find_all(client, workspace: nil, per_page: 20, options: {})
          params = { workspace: workspace, limit: per_page }.reject { |_,v| v.nil? || Array(v).empty? }
          Collection.new(parse(client.get("/users", params: params, options: options)), type: self, client: client)
        end
      end

      # Returns all of a user's favorites in the given workspace, of the given type.
      # Results are given in order (The same order as Asana's sidebar).
      #
      # workspace - [Id] The workspace in which to get favorites.
      # resource_type - [Enum] The resource type of favorites to be returned.
      # options - [Hash] the request I/O options.
      def get_user_favorites(workspace: required("workspace"), resource_type: required("resource_type"), options: {})
        params = { workspace: workspace, resource_type: resource_type }.reject { |_,v| v.nil? || Array(v).empty? }
        Collection.new(parse(client.get("/users/#{gid}/favorites", params: params, options: options)), type: Resource, client: client)
      end

    end
  end
end
