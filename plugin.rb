# frozen_string_literal: true

# name: discourse-emoji-letter-avatar
# about: Add {first_emoji} and {name_first_letter} options for external_system_avatars_url
# version: 0.0.1
# authors: dsims
# url: https://github.com/dsims/discourse-emoji-letter-avatar

after_initialize do
  module EmojiLetterName
    def system_avatar_template(username)
      url = super(username) # uses first character in username to set {first_letter}
      # find user to check name and bio
      if %w[{name_first_letter} {first_emoji}].any? { |s| url.include?(s) }
        username = normalize_username(username)
        # potential performance issue to find user?
        user = User.find_by_username(username)
        name = normalize_username(user.name) if user
        # use first character in name/username if no emoji or to set {name_first_letter}
        name_first_letter =
          (
            if (
                 name.present? &&
                   !UsernameValidator::UNICODE_INVALID_CHAR_PATTERN.match?(
                     name.grapheme_clusters.first,
                   )
               )
              UrlHelper.encode_component(name.grapheme_clusters.first)
            else
              UrlHelper.encode_component(username.grapheme_clusters.first)
            end
          )
        url.gsub! "{name_first_letter}", name_first_letter
        if url.include?("{first_emoji}")
          return url.gsub("{first_emoji}", name_first_letter) unless user
          first_emoji =
            [name, user.user_profile&.bio_raw].lazy
              .filter_map do |str|
                str = Emoji.gsub_emoji_to_unicode(str)
                str ? (str.grapheme_clusters & Emoji.unicode_replacements.keys).first : nil
              end
              .first
          url.gsub! "{first_emoji}", UrlHelper.encode_component(first_emoji) || name_first_letter
        end
      end
      url
    end
  end
  User.singleton_class.prepend EmojiLetterName
end
