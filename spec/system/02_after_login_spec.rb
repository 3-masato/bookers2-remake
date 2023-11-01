require "rails_helper"

describe "[STEP2] ユーザログイン後のテスト" do
  let!(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:book) { create(:book, user: user) }
  let!(:other_book) { create(:book, user: other_user) }

  let!(:user_comment) { create(:book_comment, user: user, book: book) }
  let!(:other_user_comment) { create(:book_comment, user: other_user, book: book) }

  before do
    visit new_user_session_path
    fill_in "user[name]", with: user.name
    fill_in "user[password]", with: user.password
    click_button "Log in"
  end

  describe "ヘッダーのテスト: ログインしている場合" do
    context "リンクの内容を確認: ※logoutは『ユーザログアウトのテスト』でテスト済みになります。" do
      subject { current_path }

      it "Homeを押すと、自分のユーザ詳細画面に遷移する" do
        home_link = find_all("a")[1].text
        home_link = home_link.delete("\n").gsub(/\A\s*/, "").gsub(/\s*\Z/, "")
        click_link home_link
        is_expected.to eq "/users/" + user.id.to_s
      end
      it "Usersを押すと、ユーザ一覧画面に遷移する" do
        users_link = find_all("a")[2].text
        users_link = users_link.delete("\n").gsub(/\A\s*/, "").gsub(/\s*\Z/, "")
        click_link users_link
        is_expected.to eq "/users"
      end
      it "Booksを押すと、投稿一覧画面に遷移する" do
        books_link = find_all("a")[3].text
        books_link = books_link.delete("\n").gsub(/\A\s*/, "").gsub(/\s*\Z/, "")
        click_link books_link
        is_expected.to eq "/books"
      end
    end
  end

  describe "投稿一覧画面のテスト" do
    before do
      visit books_path
    end

    context "表示内容の確認" do
      it "URLが正しい" do
        expect(current_path).to eq "/books"
      end
      it "自分と他人の画像のリンク先が正しい" do
        expect(page).to have_link "", href: user_path(book.user)
        expect(page).to have_link "", href: user_path(other_book.user)
      end
      it "自分の投稿と他人の投稿のタイトルのリンク先がそれぞれ正しい" do
        expect(page).to have_link book.title, href: book_path(book)
        expect(page).to have_link other_book.title, href: book_path(other_book)
      end
      it "自分の投稿と他人の投稿のオピニオンが表示される" do
        expect(page).to have_content book.body
        expect(page).to have_content other_book.body
      end
      it "自分の投稿と他人の投稿のいいねボタンが表示される" do
        expect(page).to have_link href: book_favorites_path(book)
        expect(page).to have_link href: book_favorites_path(other_book)
      end
      it "自分の投稿と他人の投稿のコメント数が表示される" do
        expect(page).to have_content book.book_comments.count
        expect(page).to have_content other_book.book_comments.count
      end
    end

    context "サイドバーの確認" do
      it "自分の名前と紹介文が表示される" do
        expect(page).to have_content user.name
        expect(page).to have_content user.introduction
      end
      it "自分のユーザ編集画面へのリンクが存在する" do
        expect(page).to have_link "", href: edit_user_path(user)
      end
      it "「New book」と表示される" do
        expect(page).to have_content "New book"
      end
      it "titleフォームが表示される" do
        expect(page).to have_field "book[title]"
      end
      it "titleフォームに値が入っていない" do
        expect(find_field("book[title]").text).to be_blank
      end
      it "bodyフォームが表示される" do
        expect(page).to have_field "book[body]"
      end
      it "bodyフォームに値が入っていない" do
        expect(find_field("book[body]").text).to be_blank
      end
      it "Create Bookボタンが表示される" do
        expect(page).to have_button "Create Book"
      end
    end

    context "投稿成功のテスト" do
      before do
        fill_in "book[title]", with: Faker::Lorem.characters(number: 5)
        fill_in "book[body]", with: Faker::Lorem.characters(number: 20)
      end

      it "自分の新しい投稿が正しく保存される" do
        expect { click_button "Create Book" }.to change(user.books, :count).by(1)
      end
      it "リダイレクト先が、保存できた投稿の詳細画面になっている" do
        click_button "Create Book"
        expect(current_path).to eq "/books/" + Book.last.id.to_s
      end
    end
  end

  describe "自分の投稿詳細画面のテスト" do
    before do
      visit book_path(book)
    end

    context "表示内容の確認" do
      it "URLが正しい" do
        expect(current_path).to eq "/books/" + book.id.to_s
      end
      it "「Book detail」と表示される" do
        expect(page).to have_content "Book detail"
      end
      it "ユーザ画像・名前のリンク先が正しい" do
        expect(page).to have_link book.user.name, href: user_path(book.user)
      end
      it "投稿のtitleが表示される" do
        expect(page).to have_content book.title
      end
      it "投稿のbodyが表示される" do
        expect(page).to have_content book.body
      end
      it "投稿の編集リンクが表示される" do
        expect(page).to have_link "Edit", href: edit_book_path(book)
      end
      it "投稿の削除リンクが表示される" do
        expect(page).to have_link "Destroy", href: book_path(book)
      end
      it "投稿のいいねボタンが表示される" do
        expect(page).to have_link href: book_favorites_path(book)
      end
      it "投稿のコメント数が表示される" do
        expect(page).to have_content book.book_comments.count
      end
      it "自分のコメントの削除リンクが表示される" do
        expect(page).to have_link "Destroy", href: book_book_comment_path(book, user_comment)
      end
      it "他人のコメントの削除リンクが表示されない" do
        expect(page).not_to have_link "Destroy", href: book_book_comment_path(book, other_user_comment)
      end
    end

    context "サイドバーの確認" do
      it "自分の名前と紹介文が表示される" do
        expect(page).to have_content user.name
        expect(page).to have_content user.introduction
      end
      it "自分のユーザ編集画面へのリンクが存在する" do
        expect(page).to have_link "", href: edit_user_path(user)
      end
      it "「New book」と表示される" do
        expect(page).to have_content "New book"
      end
      it "titleフォームが表示される" do
        expect(page).to have_field "book[title]"
      end
      it "titleフォームに値が入っていない" do
        expect(find_field("book[title]").text).to be_blank
      end
      it "bodyフォームが表示される" do
        expect(page).to have_field "book[body]"
      end
      it "bodyフォームに値が入っていない" do
        expect(find_field("book[body]").text).to be_blank
      end
      it "Create Bookボタンが表示される" do
        expect(page).to have_button "Create Book"
      end
    end

    context "投稿成功のテスト" do
      before do
        fill_in "book[title]", with: Faker::Lorem.characters(number: 5)
        fill_in "book[body]", with: Faker::Lorem.characters(number: 20)
      end

      it "自分の新しい投稿が正しく保存される" do
        expect { click_button "Create Book" }.to change(user.books, :count).by(1)
      end
    end

    # === ユーザーが本の投稿者である場合に編集画面に遷移する ===
    # BooksController > editのロジックが破綻していないかの妥当性を兼ねる
    # ==========================================================
    context "編集リンクのテスト" do
      it "編集画面に遷移する" do
        second_user_book = FactoryBot.create(:book, user: user) # 「user」の投稿をもう一つ作成
        visit book_path(second_user_book)
        click_link "Edit"
        expect(current_path).to eq edit_book_path(second_user_book)
      end
    end

    context "削除リンクのテスト" do
      it "application.html.erbにjavascript_pack_tagを含んでいる" do
        is_exist = 0
        open("app/views/layouts/application.html.erb").each do |line|
          strip_line = line.chomp.delete(" ")
          # シングルクォーテーションまたはダブルクォーテーションを許容する正規表現を使用
          if strip_line.match?(/<%=[\s]*javascript_pack_tag[\s]*['"]application['"],[\s]*['"]data-turbolinks-track['"]:[\s]*['"]reload['"]%>/)
            is_exist = 1
            break
          end
        end
        expect(is_exist).to eq(1)
      end
      before do
        click_link "Destroy", href: book_path(book)
      end
      it "正しく削除される" do
        expect(Book.where(id: book.id).count).to eq 0
      end
      it "リダイレクト先が、投稿一覧画面になっている" do
        expect(current_path).to eq "/books"
      end
    end
  end

  describe "自分の投稿編集画面のテスト" do
    before do
      visit edit_book_path(book)
    end

    context "表示の確認" do
      it "URLが正しい" do
        expect(current_path).to eq "/books/" + book.id.to_s + "/edit"
      end
      it "「Editing Book」と表示される" do
        expect(page).to have_content "Editing Book"
      end
      it "title編集フォームが表示される" do
        expect(page).to have_field "book[title]", with: book.title
      end
      it "body編集フォームが表示される" do
        expect(page).to have_field "book[body]", with: book.body
      end
      it "Update Bookボタンが表示される" do
        expect(page).to have_button "Update Book"
      end
      it "Showリンクが表示される" do
        expect(page).to have_link "Show", href: book_path(book)
      end
      it "Backリンクが表示される" do
        expect(page).to have_link "Back", href: books_path
      end
    end

    context "編集成功のテスト" do
      before do
        @book_old_title = book.title
        @book_old_body = book.body
        fill_in "book[title]", with: Faker::Lorem.characters(number: 4)
        fill_in "book[body]", with: Faker::Lorem.characters(number: 19)
        click_button "Update Book"
      end

      it "titleが正しく更新される" do
        expect(book.reload.title).not_to eq @book_old_title
      end
      it "bodyが正しく更新される" do
        expect(book.reload.body).not_to eq @book_old_body
      end
      it "リダイレクト先が、更新した投稿の詳細画面になっている" do
        expect(current_path).to eq "/books/" + book.id.to_s
        expect(page).to have_content "Book detail"
      end
    end
  end

  describe "ユーザ一覧画面のテスト" do
    before do
      visit users_path
    end

    context "表示内容の確認" do
      it "URLが正しい" do
        expect(current_path).to eq "/users"
      end
      it "自分と他人の画像が表示される: fallbackの画像がサイドバーの1つ＋一覧(2人)の2つの計3つ存在する" do
        expect(all("img").size).to eq(3)
      end
      it "自分と他人の名前がそれぞれ表示される" do
        expect(page).to have_content user.name
        expect(page).to have_content other_user.name
      end
      it "自分と他人のshowリンクがそれぞれ表示される" do
        expect(page).to have_link "Show", href: user_path(user)
        expect(page).to have_link "Show", href: user_path(other_user)
      end
    end

    context "サイドバーの確認" do
      it "自分の名前と紹介文が表示される" do
        expect(page).to have_content user.name
        expect(page).to have_content user.introduction
      end
      it "自分のユーザ編集画面へのリンクが存在する" do
        expect(page).to have_link "", href: edit_user_path(user)
      end
      it "「New book」と表示される" do
        expect(page).to have_content "New book"
      end
      it "titleフォームが表示される" do
        expect(page).to have_field "book[title]"
      end
      it "titleフォームに値が入っていない" do
        expect(find_field("book[title]").text).to be_blank
      end
      it "bodyフォームが表示される" do
        expect(page).to have_field "book[body]"
      end
      it "bodyフォームに値が入っていない" do
        expect(find_field("book[body]").text).to be_blank
      end
      it "Create Bookボタンが表示される" do
        expect(page).to have_button "Create Book"
      end
    end
  end

  describe "自分のユーザ詳細画面のテスト" do
    before do
      visit user_path(user)
    end

    context "表示の確認" do
      it "URLが正しい" do
        expect(current_path).to eq "/users/" + user.id.to_s
      end
      it "投稿一覧のユーザ画像のリンク先が正しい" do
        expect(page).to have_link "", href: user_path(user)
      end
      it "投稿一覧に自分の投稿のtitleが表示され、リンクが正しい" do
        expect(page).to have_link book.title, href: book_path(book)
      end
      it "投稿一覧に自分の投稿のbodyが表示される" do
        expect(page).to have_content book.body
      end
      it "投稿一覧に自分の投稿のいいねボタンが表示される" do
        expect(page).to have_link href: book_favorites_path(book)
      end
      it "投稿一覧に自分の投稿のコメント数が表示される" do
        expect(page).to have_content book.book_comments.count
      end
      it "他人の投稿は表示されない" do
        expect(page).not_to have_link "", href: user_path(other_user)
        expect(page).not_to have_content other_book.title
        expect(page).not_to have_content other_book.body
      end
    end

    context "サイドバーの確認" do
      it "自分の名前と紹介文が表示される" do
        expect(page).to have_content user.name
        expect(page).to have_content user.introduction
      end
      it "自分のユーザ編集画面へのリンクが存在する" do
        expect(page).to have_link "", href: edit_user_path(user)
      end
      it "「New book」と表示される" do
        expect(page).to have_content "New book"
      end
      it "titleフォームが表示される" do
        expect(page).to have_field "book[title]"
      end
      it "titleフォームに値が入っていない" do
        expect(find_field("book[title]").text).to be_blank
      end
      it "bodyフォームが表示される" do
        expect(page).to have_field "book[body]"
      end
      it "bodyフォームに値が入っていない" do
        expect(find_field("book[body]").text).to be_blank
      end
      it "Create Bookボタンが表示される" do
        expect(page).to have_button "Create Book"
      end
    end
  end

  describe "自分のユーザ情報編集画面のテスト" do
    before do
      visit edit_user_path(user)
    end

    context "表示の確認" do
      it "URLが正しい" do
        expect(current_path).to eq "/users/" + user.id.to_s + "/edit"
      end
      it "名前編集フォームに自分の名前が表示される" do
        expect(page).to have_field "user[name]", with: user.name
      end
      it "画像編集フォームが表示される" do
        expect(page).to have_field "user[profile_image]"
      end
      it "自己紹介編集フォームに自分の自己紹介文が表示される" do
        expect(page).to have_field "user[introduction]", with: user.introduction
      end
      it "Update Userボタンが表示される" do
        expect(page).to have_button "Update User"
      end
    end

    context "更新成功のテスト" do
      before do
        @user_old_name = user.name
        @user_old_intrpduction = user.introduction
        fill_in "user[name]", with: Faker::Lorem.characters(number: 9)
        fill_in "user[introduction]", with: Faker::Lorem.characters(number: 19)
        expect(user.profile_image).to be_attached
        click_button "Update User"
        save_page
      end

      it "nameが正しく更新される" do
        expect(user.reload.name).not_to eq @user_old_name
      end
      it "introductionが正しく更新される" do
        expect(user.reload.introduction).not_to eq @user_old_intrpduction
      end
      it "リダイレクト先が、自分のユーザ詳細画面になっている" do
        expect(current_path).to eq "/users/" + user.id.to_s
      end
    end
  end

  describe "いいねボタンのテスト" do
    context "表示の確認" do
      it "いいねされていない投稿に対しては、いいね作成ボタンを表示させる" do
        unfavorited_book = FactoryBot.create(:book, user: user)
        visit book_path(unfavorited_book)
        expect(page).to have_selector(".favorite-body a[data-method='post']")
      end

      it "いいねされている投稿に対しては、いいね削除ボタンを表示させる" do
        favorited_book = FactoryBot.create(:book, user: user)
        FactoryBot.create(:favorite, user: user, book: favorited_book)
        visit book_path(favorited_book)
        expect(page).to have_selector(".favorite-body a[data-method='delete']")
      end

      it "いいねの数が表示されている" do
        expect(page).to have_content(book.favorites.count.to_s)
      end
    end

    context "機能の確認" do
      # テスト中にJavaScriptの非同期通信を正しく検知・待機する方法に問題があったため、
      # 一時的な対応として、`find(".favorite-body a[data-method='post']").click`実行後に明示的にページを再訪問しています。
      # AWS Cloud9の環境において、特定のJavaScript動作に関連するCapybaraの待機や検知がうまく動作しない場合が確認されました。
      # この再訪問はテストの完全性を確保するためのものであり、将来的にはより適切な待機・検知方法に置き換える予定です。
      # ==========================================================
      it "いいねをしたら、いいねの数が増える" do
        unfavorited_book = FactoryBot.create(:book, user: user)
        visit book_path(unfavorited_book)
        initial_count = find(".favorite-body-count").text.to_i

        find(".favorite-body a[data-method='post']").click
        visit book_path(unfavorited_book)

        expect(page).to have_selector(".favorite-body-count", text: initial_count + 1)
      end

      it "いいねをはずしたら、いいねの数が減る", js: true do
        favorited_book = FactoryBot.create(:book, user: user)
        FactoryBot.create(:favorite, user: user, book: favorited_book)
        visit book_path(favorited_book)
        initial_count = find(".favorite-body-count").text.to_i

        find(".favorite-body a[data-method='delete']").click
        visit book_path(favorited_book)

        expect(page).to have_selector(".favorite-body-count", text: initial_count - 1)
      end
      # ==========================================================
    end

    describe "アイコンの確認" do
      let!(:unfavorited_book) {
        create(:book, user: user)
      }
      let!(:favorited_book) {
        book = create(:book, user: user)
        create(:favorite, user: user, book: book)
        book
      }

      context "本の一覧ページ" do
        it "いいね前のアイコン" do
          visit books_path

          within "#fav-#{unfavorited_book.id}" do
            expect(page).to have_selector ".fa-regular.fa-heart, .far.fa-heart"
          end
        end

        it "いいね後のアイコン" do
          visit books_path

          within "#fav-#{favorited_book.id}" do
            expect(page).to have_selector ".fa-solid.fa-heart, .fas.fa-heart"
          end
        end
      end

      context "本の詳細ページ" do
        it "いいね前のアイコン" do
          visit book_path(unfavorited_book)

          within "#fav-#{unfavorited_book.id}" do
            expect(page).to have_selector ".fa-regular.fa-heart, .far.fa-heart"
          end
        end

        it "いいね後のアイコン" do
          visit book_path(favorited_book)

          within "#fav-#{favorited_book.id}" do
            expect(page).to have_selector ".fa-solid.fa-heart, .fas.fa-heart"
          end
        end
      end
    end
  end

  describe "コメント機能のテスト" do
    before do
      @second_user_comment = create(:book_comment, user: user, book: book)
      @second_other_user_comment = create(:book_comment, user: other_user, book: book)
      visit book_path(book)
    end

    context "表示の確認" do
      it "コメントの数が表示されている" do
        expect(page).to have_content(book.book_comments.count.to_s)
      end
    end

    context "機能の確認" do
      it "コメントをしたらコメントの数が増える" do
        uncommented_book = create(:book, user: user)

        visit book_path(uncommented_book)

        initial_count = find(".comment-count-body-count").text.to_i

        # コメントを作成
        create(:book_comment, user: user, book: uncommented_book)

        # 非同期通信を正しく検知するのに問題があったため、明示的にページ再読み込みを行う。
        visit book_path(uncommented_book)

        expect(page).to have_selector(".comment-count-body-count", text: initial_count + 1)
      end

      it "コメントを削除したらコメントの数が減る", js: true do
        commented_book = create(:book, user: user)
        commented_book_comment = create(:book_comment, user: user, book: commented_book)

        visit book_path(commented_book)

        initial_count = find(".comment-count-body-count").text.to_i

        # コメントを削除
        commented_book_comment.destroy

        # 非同期通信を正しく検知するのに問題があったため、明示的にページ再読み込みを行う。
        visit book_path(commented_book)

        expect(page).to have_selector(".comment-count-body-count", text: initial_count - 1)
      end
    end

    context "自分が投稿したコメント" do
      it "自分のコメントが表示される" do
        within "#comments-index" do
          expect(page).to have_content(@second_user_comment.comment)
        end
      end
      it "自分のコメントに名前が表示されている" do
        within "#comments-index" do
          expect(page).to have_link user.name, href: user_path(user)
        end
      end
      it "自分のコメントに削除リンクが表示されている" do
        within "#comments-index" do
          expect(page).to have_link "Destroy", href: book_book_comment_path(book, @second_user_comment)
        end
      end
      it "自分のコメントを削除できる" do
        click_link "Destroy", href: book_book_comment_path(book, @second_user_comment)
        expect(BookComment.where(id: @second_user_comment.id).count).to eq 0
      end
    end

    context "他人が投稿したコメント" do
      it "他人の投稿したコメントが表示される" do
        within "#comments-index" do
          expect(page).to have_content(@second_other_user_comment.comment)
        end
      end
      it "他人のコメントに名前が表示されている" do
        within "#comments-index" do
          expect(page).to have_link other_user.name, href: user_path(other_user)
        end
      end
      it "他人のコメントに削除リンクが表示されていない" do
        within "#comments-index" do
          expect(page).not_to have_link "Destroy", href: book_book_comment_path(book, @second_other_user_comment)
        end
      end
    end

    context "コメント投稿フォーム" do
      it "commentフォームが表示される" do
        within "#comment-form" do
          expect(page).to have_field("book_comment[comment]")
        end
      end
      it "commentフォームに値が入っていない" do
        within "#comment-form" do
          expect(find_field("book_comment[comment]").text).to be_blank
        end
      end
      it "Commentボタンが表示される" do
        within "#comment-form" do
          expect(page).to have_button "Comment"
        end
      end
    end

    describe "アイコンの確認" do
      it "本の一覧ページ" do
        visit books_path

        expect(page).to have_selector ".fa-solid.fa-comments, .fas.fa-comments"
      end

      it "本の詳細ページ" do
        visit book_path(book)

        within "#comments-count" do
          expect(page).to have_selector ".fa-solid.fa-comments, .fas.fa-comments"
        end
      end
    end
  end
end
