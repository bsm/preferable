require 'spec_helper'

describe Preferable::Model do

  subject do
    Class.new(ActiveRecord::Base)
  end

  it 'should be includable' do
    subject.send(:included_modules).should include(described_class)
  end

  it 'should allow to define preferables' do
    res = nil
    subject.preferable.should be_a(Preferable::Schema)
    subject.preferable { res = self.class.name }
    res.should == "Preferable::Schema"
  end

  describe "instances" do
    subject do
      User.new
    end

    it 'should have preferences' do
      subject.preferences.should be_a(Preferable::Set)
    end

    it 'should allow assigning preferences' do
      subject.preferences = { :color => '222222' }
      subject.preferences.should be_a(Preferable::Set)
      subject.preferences.should == { "_" => "::User", :color => '222222' }
    end

    it 'should serialize preferences' do
      subject.class.serialized_attributes.should == { "preferences" => Preferable::Set }
    end

  end
end
