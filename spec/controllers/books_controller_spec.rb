require 'spec_helper'

describe BooksController, :type => :controller do

  describe "GET index" do
    before :each do
      allow(Book).to receive(:all).and_return([])
    end
    it "sends all message to Book" do
      expect(Book).to receive(:all)
      get :index
    end
    it "assignes @books variable to the view" do
      get :index
      expect(assigns[:books]).to eq([])
    end
    it "renders :index template" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe "GET new" do

    let!(:book) { mock_model("Book").as_new_record }

    context "when reader is logged in" do
      before :each do
        session[:reader_id] = 1
      end

      it "assigns book variable to view" do
        allow(Book).to receive(:new).and_return(book)
        get :new
        expect(assigns[:book]).to eq(book)
      end
      it "renders new template" do
        get :new
        expect(response).to render_template :new
      end
    end

    context "when reader is not logged in" do
      before :each do
        session[:reader_id] = nil
      end
      it "redirects to access denied page" do
        get :new
        expect(response).to redirect_to access_denied_path
      end

    end
  end

  describe "GET show" do
    context "book exists" do
      let!(:book) { stub_model(Book) }
      before :each do
        allow(Book).to receive(:find).and_return(book)
      end

      it "sends find message to Book class" do
        expect(Book).to receive(:find).with("1")
        get :show, id: 1
      end
      it "assigns @book to the view" do
        get :show, id: 1
        expect(assigns[:book]).to eq(book)
      end
      it "renders show template" do
        get :show, id: 1
        expect(response).to render_template :show
      end
    end

    context "book doesn't exist" do
      before :each do
        allow(Book).to receive(:find).and_raise(ActiveRecord::RecordNotFound)
      end
      it "redirects to not found page" do
        get :show, id: 1
        expect(response).to redirect_to root_path
      end
      it "assigns flash[:error]" do
        get :show, id: 0
        expect(flash[:error]).not_to be_nil
      end

    end

  end

  describe "GET edit" do
    let!(:book) { stub_model(Book, id: 1) }
    before :each do
      allow(Book).to receive(:find).and_return(book)
    end

    context "when reader is the owner" do
      before :each do
        allow(book).to receive(:owned_by?).and_return(true)
      end

      it "assigns book variable to view" do
        get :edit, id: book.id
        expect(assigns[:book]).to eq(book)
      end
      it "renders new template" do
        get :edit, id: book.id
        expect(response).to render_template :edit
      end
    end

    context "when reader is not the owner" do
      before :each do
        allow(book).to receive(:owned_by?).and_return(false)
      end
      it "redirects to access denied page" do
        get :edit, id: book.id
        expect(response).to redirect_to access_denied_path
      end
    end
 
  end

  describe "PUT update" do
    let(:params) do
      {
        "title" => "title",
        "author" => "author",
        "pages" => "123",
        "description" => "description"
      }
    end

    let!(:book) { stub_model(Book, id: 1) }

    before :each do
      allow(Book).to receive(:find).and_return(book)
    end

    it "sends find message" do
      expect(Book).to receive(:find)
      put :update, id: book.id, book: params
    end
    it "sends update_attributes message with provided params" do
      expect(book).to receive(:update_attributes)
      put :update, id: book.id, book: params
    end

    context "when update_attributes returns true" do
      before :each do
        allow(book).to receive(:update_attributes).and_return(true)
        put :update, id: book.id, book: params
      end
      it "redirects to library page" do
        expect(response).to redirect_to books_path
      end
      it "assigns flash[:notice]" do
        expect(flash[:notice]).not_to be_nil
      end
    end

    context "when update_attributes returns false" do
      before :each do
        allow(book).to receive(:update_attributes).and_return(false)
        put :update, id: book.id, book: params
      end
      it "renders edit tempate" do
        expect(response).to render_template :edit
      end
      it "assings @book variable to view" do
        expect(assigns[:book]).to eq(book)
      end
      it "assings flash[:error]" do
        expect(flash[:error]).not_to be_nil
      end

    end

  end

  describe "POST create" do
    
    let(:params) do
      {
        "title" => "title",
        "author" => "author",
        "pages" => "123",
        "description" => "description"
      }
    end

    context "when reader is logged in" do

      let!(:book) { stub_model(Book) }
      before :each do
        allow(Book).to receive(:new).and_return(book)
        session[:reader_id] = 1
      end

      it "can mass-assign parameters" do
        Book.unstub(:new)
        post :create, book: params
      end

      it "sends new message with params to book model" do
        expect(Book).to receive(:new).with(params)
        post :create, book: params
      end
      it "sends save message to book model" do
        expect(book).to receive(:save)
        post :create, book: params
      end
      it "sends reader_id= message to book model" do
        expect(book).to receive(:reader_id=).with(1)
        post :create, book: params
      end

      context "valid data" do
        before :each do
          allow(book).to receive(:save).and_return(true)
        end
        it "redirects to index page" do
          post :create, book: params
          expect(response).to redirect_to books_url
        end
        it "assign flash[:notice]" do
          post :create, book: params
          expect(flash[:notice]).not_to be_nil
        end
      end

      context "invalid data" do
        before :each do
          allow(book).to receive(:save).and_return(false)
          post :create, book: params
        end
        it "renders new template" do
          expect(response).to render_template :new
        end
        it "assigns flash[:error] message" do 
          expect(flash[:error]).not_to be_nil
        end
        it "assigns @book variable" do
          expect(assigns[:book]).to eq(book)
        end
      end
    end

    context "when user is not logged in" do
      before :each do
        session[:reader_id] = nil
      end
      it "redirects to access denied page" do
        post :create
        expect(response).to redirect_to access_denied_path
      end
    end

  end

  describe "DELETE destroy" do
    let!(:book) { stub_model(Book, id: 1) }
    before :each do
      allow(Book).to receive(:find).and_return(book)
      allow(book).to receive(:destroy).and_return(true)
    end
    it "sends find" do
      expect(Book).to receive(:find).with(book.id.to_s)
      delete :destroy, id: book.id
    end

    context "when reader is the owner" do
      before :each do
        allow(book).to receive(:owned_by?).and_return(true)
      end
      it "sends destroy" do
        expect(book).to receive(:destroy)
        delete :destroy, id: book.id
      end
      it "redirects to library page" do
        delete :destroy, id: book.id
        expect(response).to redirect_to books_path
      end
    end

    context "when reader is not the owner" do
      before :each do
        allow(book).to receive(:owned_by?).and_return(false)
      end
      it "redirects to access denied page" do
        delete :destroy, id: book.id
        expect(response).to redirect_to access_denied_path
      end

    end
  end

end
