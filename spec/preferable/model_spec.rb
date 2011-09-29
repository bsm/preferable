require 'spec_helper'

describe Preferable::Model do

  subject do
    Class.new(ActiveRecord::Base)
  end

  it 'should be includable' do
    subject.send(:included_modules).should include(described_class)
  end

  it 'should store a preferable schema' do
    User._preferable.keys.should =~ [:newsletter, :color]
  end

  it 'should inherit preferable schema correctly' do
    Admin._preferable.keys.should =~ [:newsletter, :color, :reminder]
  end

  it 'should allow to define preferables' do
    res = nil
    subject._preferable.should be_nil
    subject.preferable { res = self.class.name }
    subject._preferable.should be_a(Preferable::Schema)
    res.should == "Preferable::Schema"
  end

  describe "saving" do

    it 'should save preferences with new records' do
      user = User.new
      user.preferences.should == {}
      user.preferences[:color] = '222222'
      user.tap(&:save!).tap(&:reload).preferences.should == { :color => '222222' }
    end

    it 'should save preferences with existing records' do
      user = User.create!(:name => 'Random', :preferences => { :color => '222222' }).reload
      user.preferences.should == { :color => '222222' }
      user.preferences[:newsletter] = '1'
      user.tap(&:save!).tap(&:reload).preferences.should == { :color => '222222', :newsletter => true }
    end

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
      subject.preferences.should == { :color => '222222' }
    end

    it 'should serialize preferences' do
      subject.class.serialized_attributes.keys.should include('preferences')
    end

  end
end
