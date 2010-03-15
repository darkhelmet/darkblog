require 'active_support'

# Date class used to make archive links
class ArchiveDate < DateTime
  def succ
    nm = self + 1.month
    ArchiveDate.new(nm.year, nm.month, 1)
  end
end