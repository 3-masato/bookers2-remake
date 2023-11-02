module Searchable
  extend ActiveSupport::Concern

  class_methods do
    def search_for(attribute, content, conditions)
      case conditions
      when "exact"
        where(attribute => content)
      when "forward"
        where("#{attribute} LIKE ?", content + "%")
      when "backward"
        where("#{attribute} LIKE ?", "%" + content)
      when "partial"
        where("#{attribute} LIKE ?", "%" + content + "%")
      end
    end
  end
end
