class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  validates :email, presence: true
  validate :check_mail

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, :omniauth_providers => [:google_oauth2]

  def self.from_omniauth(auth)
    where(email: auth.info.email).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.name = auth.info.name   # assuming the user model has a name
      #user.image = auth.info.image # assuming the user model has an image
    end
  end

  def super_admin?
    admin_emails = YAML::load_file('config/superadmin.yml')
    admin_emails['superadmin'].include?(self.email)
  end

  private

  def check_mail
    unless self.email.end_with?('nascenia.com') || self.email.end_with?('bdipo.com')
      self.errors.add(:email, 'Only Nascenia employee can use this application')
    end
  end
end
