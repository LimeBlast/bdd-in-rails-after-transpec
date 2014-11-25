require 'spec_helper'

describe "books/show.html.erb", :type => :view do

  let(:book) { stub_model(Book, title: "book1", author: "author", description: "desc") }
  before :each do
    allow(view).to receive(:current_user).and_return(stub_model(Reader))
    allow(book).to receive(:owned_by?)
    assign(:book, book)
  end

  it "has title" do
    render
    expect(rendered).to have_content(book.title)
  end
  it "has author" do
    render
    expect(rendered).to have_content(book.author)
  end
  it "has description" do
    render
    expect(rendered).to have_content(book.description)
  end
  it "has cover image" do
    render
    expect(rendered).to have_selector("img#cover")
  end

  context "when reader is the owner" do
    before :each do
      allow(book).to receive(:owned_by?).and_return(true)
    end
    it "has delete link" do
    render
      expect(rendered).to have_link("Delete")
    end
    it "has edit link" do
    render
      expect(rendered).to have_link("Edit", href: edit_book_path(book))
    end
  end

  context "when reader is not the owner" do
    before :each do
      allow(book).to receive(:owned_by?).and_return(false)
    end
    it "doesn't have delete link" do
    render
      expect(rendered).not_to have_link("Delete")
    end
    it "doesn't have edit link" do
    render
      expect(rendered).not_to have_link("Edit", href: edit_book_path(book))
    end
  end


end
