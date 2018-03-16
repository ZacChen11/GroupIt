module ApplicationHelper

  def get_user_name(creation)
    if creation.user
      creation.user.user_name
    else
      "Null"
    end
  end


end
