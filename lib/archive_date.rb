require 'active_support'

# Date class used to make archive links
class ArchiveDate < Date
  def succ
    self + 1.month
  end
end