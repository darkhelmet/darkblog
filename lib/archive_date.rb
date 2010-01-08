require 'active_support'

class ArchiveDate < Date
  def succ
    self + 1.month
  end
end