# Be sure to restart your server when you modify this file. Action Cable runs in an EventMachine loop that does not support auto reloading.
module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      byebug
      self.current_user = find_verified_user
      # logger.add_tags 'ActionCable', current_user.name
    end

    protected
      def find_verified_user
        if current_user = User.find_by(id: cookies.signed[:user_id])
          current_user
        else
          reject_unauthorized_connection
        end
      end
  end
end

# module ApplicationCable
#   class Connection < ActionCable::Connection::Base
#     identified_by :current_user

#     def connect
#       self.current_user = User.last || find_verified_user
#       logger.add_tags 'ActionCable', current_user.name
#     end

#     protected
#       def find_verified_user
#         if verified_user = User.find_by(id: cookies.signed[:user_id])
#           verified_user
#         else
#           reject_unauthorized_connection
#         end
#       end
#   end
# end
