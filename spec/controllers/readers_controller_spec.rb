require 'spec_helper'

describe ReadersController, :type => :controller do
  describe "GET new" do
    let!(:reader) {mock_model("Reader").as_new_record}

    before :each do
      allow(Reader).to receive(:new).and_return(reader)
    end

    it "renders new template" do
      get :new
      expect(response).to render_template :new
    end
    it "assigns @reader variable to the view" do
      get :new
      expect(assigns[:reader]).to eq(reader)
    end
  end

  describe "POST create" do
    let!(:reader) { stub_model(Reader, params) }
    let(:params) do
      {
        "email" => "email@email.com",
        "password" => "pass",
        "password_confirmation" => "pass"
      }
    end
    let(:email) { double("Message", deliver: true) }
    before :each do
      allow(Reader).to receive(:new).and_return(reader)
      allow(ReaderMailer).to receive(:welcome).and_return(email)
    end
    it "sends new message to Reader class" do
      expect(Reader).to receive(:new).with(params)
      post :create, reader: params
    end
    it "sends save message to reader model" do
      expect(reader).to receive(:save)
      post :create, reader: params
    end

    context "when save message returns true" do
      before :each do
        allow(reader).to receive(:save).and_return(true)
      end
      it "redirects to root url" do
        post :create, reader: params
        expect(response).to redirect_to root_url
      end
      it "assings a success flash message" do
        post :create, reader: params
        expect(flash[:notice]).not_to be_nil
      end
      it "logs in reader" do
        post :create, reader: params
        expect(session[:reader_id]).to eq(reader.id)
      end
      it "delivers welcome email message" do
        expect(ReaderMailer).to receive(:welcome).with(params["email"])
        expect(email).to receive(:deliver)
        post :create, reader: params
      end
    end

    context "when save message return false" do
      before :each do
        allow(reader).to receive(:save).and_return(false)
        post :create, reader: params
      end
      it "renders new template" do
        expect(response).to render_template :new
      end
      it "assigns reader variable to the view" do
        expect(assigns[:reader]).to eq(reader)
      end
      it "assigns error flash message" do
        expect(flash[:error]).not_to be_nil
      end
    end
  end
end
