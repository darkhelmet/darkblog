class Keyword < ActiveRecord::Base
  has_many :keywordings, :dependent => :destroy
  has_many :posts, :through => :keywordings

  def to_s
    name
  end
end