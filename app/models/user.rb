class User < ActiveRecord::Base
  devise :omniauthable, omniauth_providers: [:github]

  def self.from_omniauth(auth_response)
    if existing_user = where(uid: auth_response.uid).first
      Rails.logger.debug "\nupdating existing user\n"
      existing_user.encrypted_password = auth_response.credentials.token
      existing_user.save
      existing_user
    else
      Rails.logger.debug "\ncreating a new user\n"
      new_user = new
      new_user.uid = auth_response.uid
      new_user.provider = auth_response.provider
      new_user.email = auth_response.info.email
      new_user.encrypted_password = auth_response.credentials.token
      new_user.save
      new_user
    end
  end
end
