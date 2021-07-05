# frozen_string_literal: true

# Class
class ApplicationRecord < ActiveRecord::Base
  acts_as_paranoid
  self.abstract_class = true
end
