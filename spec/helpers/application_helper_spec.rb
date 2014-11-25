require 'spec_helper'

describe ApplicationHelper, :type => :helper do

  describe "#top_menu" do
    it "has Register link if reader is not logged in" do
      allow(helper).to receive(:current_user).and_return(nil)
      expect(helper.top_menu).to have_link("Register")
    end
    it "has welcome reader message if reader is logged in" do
      reader = double("Reader", email: "email@email.com")
      allow(helper).to receive(:current_user).and_return(reader)
      expect(helper.top_menu).to have_content("Welcome, #{reader.email}")
    end
  end

end
