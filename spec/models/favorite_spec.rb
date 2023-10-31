require "rails_helper"

RSpec.describe "Favoriteモデルのテスト", type: :model do
  describe "バリデーションのテスト" do
    let(:user) { create(:user) }
    let(:book) { build(:book, user_id: user.id) }

    context "ユーザーが本を複数回いいねしようとしたとき" do
      before do
        # 一度いいねをする
        Favorite.create(user: user, book: book)
      end

      it "同じユーザーが同じ本を複数回いいねできないこと" do
        # 同じuser_idとbook_idで再度いいねを試みる
        duplicate_favorite = Favorite.new(user: user, book: book)
        expect(duplicate_favorite.valid?).to be false
        expect(duplicate_favorite.errors[:user_id]).to include("has already been taken")
      end
    end
  end

  describe "アソシエーションのテスト" do
    context "Userモデルとの関係" do
      it "N:1となっている" do
        expect(Favorite.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end

    context "Bookモデルとの関係" do
      it "N:1となっている" do
        expect(Favorite.reflect_on_association(:book).macro).to eq :belongs_to
      end
    end
  end
end
