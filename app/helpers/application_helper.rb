module ApplicationHelper
  def age_in_years(birth_date)
    return unless birth_date
    now = Time.zone.today
    age = now.year - birth_date.year
    age -= 1 if birth_date.to_date.change(year: now.year) > now

    if age < 0
      "まだ誕生していません"
    else
      "#{age}歳"
    end
  end
end
