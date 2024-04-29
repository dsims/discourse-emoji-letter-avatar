# **Emoji Letter Avatar** Discourse Plugin

**Plugin Summary**

Adds new replacement options to `external_system_avatars_url`. Indended for use with the Emoji Font added to the [letter_avatar](https://github.com/dsims/letter-avatars/tree/emoji) service.

* `{first_emoji}` wlll be the first emoji found anywhere in the User's `name` or `bio` (in that order) with a fallback to `name_first_letter` below.
* `{name_first_letter}` will be the first character in the User's `name`, with a fallback to `username`.

