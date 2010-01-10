class Keywording < ActiveRecord::Base
  belongs_to :keyword
  belongs_to :post
end