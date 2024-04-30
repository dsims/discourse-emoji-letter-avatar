# frozen_string_literal: true

RSpec.describe User do
  before do
    SiteSetting.unicode_usernames = true
    SiteSetting.external_system_avatars_enabled = true
  end
  let!(:user) { Fabricate(:user, username: "Lo\u0308we", name: "Francis") }
  let!(:user_bahut) { Fabricate(:user, username: "बहुत", name: "Bob") }
  let!(:user_emoji) { Fabricate(:user, username: "emoji", name: "Francis 🦋") }

  describe ".system_avatar_template" do
    context "with {name_first_letter}" do
      before do
        SiteSetting.external_system_avatars_url =
          "/letter_avatar_proxy/v4/letter/{name_first_letter}/{color}/{size}.png"
      end

      it "uses the name" do
        expect(User.system_avatar_template("Lo\u0308we")).to match(
          %r|/letter_avatar_proxy/v\d/letter/f/71e660/{size}.png|,
        )
        expect(User.system_avatar_template("L\u00F6wE")).to match(
          %r|/letter_avatar_proxy/v\d/letter/f/71e660/{size}.png|,
        )
        expect(User.system_avatar_template("बहुत")).to match(
          %r|/letter_avatar_proxy/v\d/letter/b/ea5d25/{size}.png|,
        )
      end
      describe "without name" do
        let!(:user_bahut) { Fabricate(:user, username: "बहुत", name: "") }
        it "uses username" do
          expect(User.system_avatar_template("बहुत")).to match(
            %r|/letter_avatar_proxy/v\d/letter/%E0%A4%AC/ea5d25/{size}.png|,
          )
        end
      end
      describe "with invalid name character" do
        let!(:user_bahut) { Fabricate(:user, username: "बहुत", name: ":awesome:") }
        it "uses username" do
          expect(User.system_avatar_template("बहुत")).to match(
            %r|/letter_avatar_proxy/v\d/letter/%E0%A4%AC/ea5d25/{size}.png|,
          )
        end
      end
    end

    context "with {first_emoji}" do
      let!(:color) { User.letter_avatar_color(User.normalize_username("emoji")) }
      let!(:urlencoded_emoji) { "%F0%9F%A6%8B" }
      before do
        SiteSetting.external_system_avatars_url =
          "/letter_avatar_proxy/v4/letter/{first_emoji}/{color}/{size}.png"
      end
      # U+1F98B
      # %F0%9F%A6%8B
      it "uses the emoji in name" do
        expect(User.system_avatar_template(user_emoji.username)).to match(
          %r|/letter_avatar_proxy/v\d/letter/#{urlencoded_emoji}/#{color}/{size}.png|,
        )
      end
      describe "with emoji in the bio" do
        let!(:user_emoji) { Fabricate(:user, username: "emoji", name: "Francis") }
        it "uses the emoji" do
          user_emoji.user_profile.update!(bio_raw: "Fly like a 🦋")
          expect(User.system_avatar_template(user_emoji.username)).to match(
            %r|/letter_avatar_proxy/v\d/letter/#{urlencoded_emoji}/#{color}/{size}.png|,
          )
        end
      end
      describe "with emoji-name in the bio" do
        let!(:user_emoji) { Fabricate(:user, username: "emoji", name: "Francis") }
        it "uses the emoji" do
          user_emoji.user_profile.update!(bio_raw: "Fly like a :butterfly:")
          expect(User.system_avatar_template(user_emoji.username)).to match(
            %r|/letter_avatar_proxy/v\d/letter/#{urlencoded_emoji}/#{color}/{size}.png|,
          )
        end
      end
    end
  end
end
