require "rails_helper"

RSpec.describe "BookCommentモデルのテスト", type: :model do
  describe "バリデーションのテスト" do
    subject { book_comment.valid? }

    let(:user) { create(:user) }
    let(:book) { create(:book) }
    let!(:book_comment) { build(:book_comment, user: user, book: book) }

    context "commentカラム" do
      it "空欄でないこと" do
        book_comment.comment = ""
        is_expected.to eq false
      end
    end
  end


  describe "アソシエーションのテスト" do
    context "Userモデルとの関係" do
      it "N:1となっている" do
        expect(BookComment.reflect_on_association(:user).macro).to eq :belongs_to
      end
    end

    context "Bookモデルとの関係" do
      it "N:1となっている" do
        expect(BookComment.reflect_on_association(:book).macro).to eq :belongs_to
      end
    end
  end
end
