require 'spec_helper'

describe Preferable::Coder do

  let :user do
    User.create! do |u|
      u.preferences[:newsletter] = '1'
    end.reload
  end

  let :legacy do
    User.create!
  end

  it 'should not dump blank values' do
    subject.dump(nil).should be_nil
    subject.dump("ANY").should be_nil
    subject.dump({}).should be_nil
  end

  it 'should dump hashes values' do
    subject.dump(user.preferences).should == %({"newsletter":true})
  end

  it 'should load blank values' do
    subject.load(nil).should == {}
    subject.load(" ").should == {}
  end

  it 'should load hashes as they are' do
    subject.load({"newsletter" => false}).should == {"newsletter" => false}
  end

  it 'should not fail over encoding errors' do
    subject.load("SOMETHING WRONG!?").should == {}
  end

  it 'should raise errors if something other than a hash was loaded' do
    lambda { subject.load("[1, 2]") }.should raise_error(ActiveRecord::SerializationTypeMismatch)
  end

  it 'should load values' do
    subject.load(subject.dump(user.preferences)).should == {"newsletter" => true}
  end

  it "should load legacy settings" do
    legacy.update_column :preferences, "---\n:color: \"222222\"\n_: \"::User\"\n"
    legacy.reload.preferences.should == { "color" => "222222" }

    legacy.update_column :preferences, "--- !map:Preferable::Set \n:color: \"222222\"\n_: \"::User\"\n"
    legacy.reload.preferences.should == { "color" => "222222" }

    legacy.update_column :preferences, "--- !ruby/object:Preferable::Set \n:color: \"222222\"\n_: \"::User\"\n"
    legacy.reload.preferences.should == { "color" => "222222" }
  end

end
