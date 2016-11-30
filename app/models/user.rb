class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  # devise :database_authenticatable, :registerable, :recoverable, :rememberable,
  #       :trackable, :validatable

  devise :omniauthable, omniauth_providers: [:github]

  def self.from_omniauth(res)
    where(uid: res.uid).first_or_create do |user|
      user.uid = res.uid
      user.provider = res.provider
      user.email = res.info.email
      user.encrypted_password = res.credentials.token
    end
  end
end
