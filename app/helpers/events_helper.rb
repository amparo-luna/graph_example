module EventsHelper
  def date_time_format(date_time_string)
    Time.parse(date_time_string).strftime('%D %T')
  end
end
