class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  establish_connection(:my_external_db)
end
