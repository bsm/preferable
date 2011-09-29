require 'spec_helper'

describe Preferable::Set do

  let :user do
    User.new
  end

  let :admin do
    Admin.new
  end

  subject do
    user.preferences
  end

  it 'should wrap values' do
    described_class.wrap(user, subject).should be(subject)

    described_class.wrap(admin, subject).should_not be(subject)
    described_class.wrap(admin, subject).should be_instance_of(described_class)

    described_class.wrap(user, {}).should_not be(subject)
    described_class.wrap(user, {}).should be_instance_of(described_class)
  end

  it 'should reference the owner' do
    subject.owner.should == user
  end

  it 'should be convertable to a simple hash' do
    subject.to_hash.should be_instance_of(Hash)
  end

  it 'should be serializable' do
    subject.set :color => '222222', :newsletter => '1'
    dumped = YAML.dump(subject)
    loaded = YAML.load(dumped)
    loaded.should be_instance_of(Hash)
    loaded.should == { :newsletter=>true, :color=>"222222" }
  end

  it "should NOT fail with legacy settings" do
    legacy = User.create!
    legacy.update_column :preferences, "--- !map:Preferable::Set \n:color: \"222222\"\n_: \"::User\"\n"
    legacy.reload
    legacy.preferences.should be_instance_of(Preferable::Set)
    legacy.preferences.should == { :color => "222222", "_" => "::User" }
  end

  describe "reading" do

    it 'should return assignments or defaults' do
      subject[:color].should == '444444'
      subject[:color] = '222222'
      subject[:color].should == '222222'
    end

    it 'should return nil for invalid keys' do
      subject[:invalid].should be_nil
    end

  end

  describe "writing" do

    it 'should ignore invalid keys' do
      subject[:invalid] = '1'
      subject.should == {}
    end

    it 'should set values' do
      subject[:color] = '222222'
      subject.should == { :color => '222222' }
    end

    it 'should notify record about changes' do
      subject[:color] = '222222'
      user.should be_changed
      user.changed_attributes.should == { "preferences"=>{} }
    end

    it 'should type cast values' do
      subject[:color] = 222222
      subject.should == { :color => '222222' }
    end

    it 'should unset key when defaults are assigned' do
      subject[:color] = '222222'
      subject.should == { :color => '222222' }
      subject[:color] = '444444'
      subject.should == {}
    end

    it 'should unset key when nil is assigned' do
      subject[:color] = '222222'
      subject.should == { :color => '222222' }
      subject[:color] = nil
      subject.should == {}
    end

    it 'should allow mass-update' do
      subject.set 'color' => 222222, :newsletter => '1'
      subject.should == { :color => '222222', :newsletter => true }
      subject.set :color => nil, :newsletter => false
      subject.should == {}
    end

  end
end
