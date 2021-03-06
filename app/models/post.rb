class Post < ActiveRecord::Base
  belongs_to :user
  has_many :comments
  has_many :upvotes
  has_many :upvoters, through: :upvotes, source: :user
  has_and_belongs_to_many :tags

  has_attached_file :image, 
                    :styles => { :medium => "300x300>", :thumb => "100x100>" },
                    storage: :s3,
                    s3_credentials: {access_key_id: Rails.application.secrets.s3_id,
                                     secret_access_key: Rails.application.secrets.s3_secret},
                    bucket: 'semw-instagram-clone'

  def tagstring=(tagstring)
    self.tags = tagstring.split(/[\s,]+/).map do |tag|
      Tag.find_or_create_by(name: Tag.normalise(tag))
    end
  end

  def tagstring
    self.tags.map(&:name).join(', ')
  end
  
  def creator
    user
  end

  def link=(url)
    return if url.blank?
    url = "http://#{url}" if URI.parse(url).scheme.nil?
    self['link'] = URI.parse(url).to_s
  end
end
