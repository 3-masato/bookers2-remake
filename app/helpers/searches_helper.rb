module SearchesHelper
  def search_target
    {
      "User" => "user",
      "Book" => "book"
    }
  end

  def search_conditions
    {
      "Exact Match" => "exact",
      "Forward Match" => "forward",
      "Backward Match" => "backward",
      "Partial Match" => "partial"
    }
  end

  def no_result_text
    "Oops! Didn't find what you were looking for? Maybe try different keywords or adjust your search criteria and try again!"
  end
end
