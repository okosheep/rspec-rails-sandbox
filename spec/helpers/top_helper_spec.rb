require "rails_helper"

describe TopHelper do

  context "User-Agent is Mozilla/5.0" do
    let(:helper) do
      double("helper", :request => double("request", :env => {"HTTP_USER_AGENT" => "Mozilla/5.0"})).extend(TopHelper)
    end
    it " shows user-agent is Mozilla/5.0" do
      expect(helper.print_top).to eq "User-Agent is Mozilla/5.0"
    end
  end

  context "User-Agent is nil" do
    let(:helper) do
      double("helper", :request => double("request", :env => {"HTTP_USER_AGENT" => "aaa"})).extend(TopHelper)
    end
    it " shows user-agent is Mozilla/5.0" do
      expect(helper.print_top).to eq "User-Agent is aaa"
    end
  end
end