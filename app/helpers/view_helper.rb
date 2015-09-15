module ViewHelper
  def number_to_euros number
    number_to_currency(number, locale: :es)
  end

  # def default_locale? locale
  #   I18n.default_locale == locale
  # end
  #
  # def language_selector
  #   I18n.available_locales.map do |locale|
  #     link_to(locale, default_locale?(locale) ? "/" : "/#{locale}")
  #   end.join(' | ')
  # end

  def connected?
    !!Socket.getaddrinfo("google.com", "http")
    return true
  rescue SocketError => e
    e.message != 'getaddrinfo: nodename nor servname provided, or not known'
    return false
  end

end